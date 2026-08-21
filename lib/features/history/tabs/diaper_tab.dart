import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/history/helpers/delete_confirmation.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/services/diaper_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/child/active_child_aware.dart';
import '../../../core/utils/app_date_utils.dart';
import '../widgets/history_page_shell.dart';

enum _DiaperHistoryFilter { sevenDays, thirtyDays, all, custom }

class DiaperTab extends StatefulWidget {
  const DiaperTab({super.key});

  @override
  State<DiaperTab> createState() => _DiaperTabState();
}

class _DiaperTabState extends State<DiaperTab>
    with ActiveChildAware<DiaperTab> {
  List<DiaperEntry> entries = [];
  bool loading = true;
  _DiaperHistoryFilter _filter = _DiaperHistoryFilter.sevenDays;
  DateTimeRange? _customRange;

  bool showTooltip = false;
  static const _tooltipKey = 'diaper_tab_open_count';
  DiaperEntry? recentlyDeleted;
  int? recentlyDeletedIndex;

  @override
  void initState() {
    super.initState();
    _checkTooltip();
  }

  Future<void> _checkTooltip() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_tooltipKey) ?? 0;
    if (!mounted) return;

    if (count < 3) {
      setState(() => showTooltip = true);
      await prefs.setInt(_tooltipKey, count + 1);
    }
  }

  Future<void> load() async {
    final data = await DiaperStorage().loadEntries();
    data.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (!mounted) return;
    setState(() {
      entries = data;
      loading = false;
    });
  }

  @override
  Future<void> onActiveChildChanged() => load();

  Future<void> deleteEntry(DiaperEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final index = entries.indexOf(entry);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      recentlyDeleted = entry;
      recentlyDeletedIndex = index;
      entries.removeAt(index);
    });

    try {
      await DiaperStorage().saveAllEntries(entries.reversed.toList());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        entries.insert(index, entry);
        recentlyDeleted = null;
        recentlyDeletedIndex = null;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.operationFailed)));
      return;
    }

    messenger.hideCurrentSnackBar();

    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.entryDeleted),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            if (!mounted) return;
            if (recentlyDeleted != null && recentlyDeletedIndex != null) {
              final restored = recentlyDeleted!;
              final restoredIndex = recentlyDeletedIndex!;
              setState(() {
                entries.insert(restoredIndex, restored);
                recentlyDeleted = null;
                recentlyDeletedIndex = null;
              });
              try {
                await DiaperStorage().saveAllEntries(entries.reversed.toList());
              } catch (_) {
                if (!mounted) return;
                setState(() => entries.remove(restored));
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.operationFailed)),
                );
              }
            }
          },
        ),
      ),
    );

    controller.closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        if (!mounted) return;
        setState(() {
          recentlyDeleted = null;
          recentlyDeletedIndex = null;
        });
      }
    });
  }

  List<DiaperEntry> get _filteredEntries {
    if (_filter == _DiaperHistoryFilter.all) return entries;

    late final DateTime start;
    late final DateTime endExclusive;
    if (_filter == _DiaperHistoryFilter.custom && _customRange != null) {
      start = AppDateUtils.dateOnly(_customRange!.start);
      endExclusive = AppDateUtils.dateOnly(
        _customRange!.end,
      ).add(const Duration(days: 1));
    } else {
      final days = _filter == _DiaperHistoryFilter.sevenDays ? 7 : 30;
      start = AppDateUtils.startOfRange(days);
      endExclusive = AppDateUtils.dateOnly(
        DateTime.now(),
      ).add(const Duration(days: 1));
    }

    return entries
        .where(
          (entry) =>
              !entry.timestamp.isBefore(start) &&
              entry.timestamp.isBefore(endExclusive),
        )
        .toList(growable: false);
  }

  Map<DateTime, List<DiaperEntry>> group(List<DiaperEntry> source) {
    final map = <DateTime, List<DiaperEntry>>{};

    for (final entry in source) {
      final day = AppDateUtils.dateOnly(entry.timestamp);
      map.putIfAbsent(day, () => []);
      map[day]!.add(entry);
    }

    return map;
  }

  Future<void> _pickDateRange() async {
    if (entries.isEmpty) return;

    final today = AppDateUtils.dateOnly(DateTime.now());
    final oldest = AppDateUtils.dateOnly(entries.last.timestamp);
    final thirtyDayStart = AppDateUtils.startOfRange(30);
    final defaultStart = thirtyDayStart.isBefore(oldest)
        ? oldest
        : thirtyDayStart;
    final selected = await showDateRangePicker(
      context: context,
      firstDate: oldest,
      lastDate: today,
      initialDateRange:
          _customRange ?? DateTimeRange(start: defaultStart, end: today),
    );
    if (selected == null || !mounted) return;

    setState(() {
      _customRange = DateTimeRange(
        start: AppDateUtils.dateOnly(selected.start),
        end: AppDateUtils.dateOnly(selected.end),
      );
      _filter = _DiaperHistoryFilter.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final l10n = AppLocalizations.of(context);
    final filtered = _filteredEntries;
    final grouped = group(filtered);
    final today = AppDateUtils.dateOnly(DateTime.now());

    return HistoryPageShell(
      title: l10n.diaper,
      subtitle: l10n.addDiaperChangesHint,
      icon: Icons.baby_changing_station_rounded,
      color: const Color(0xffF59E0B),
      showHeader: false,
      child: entries.isEmpty
          ? _emptyState(l10n)
          : Column(
              children: [
                _filterBar(l10n),
                Expanded(
                  child: filtered.isEmpty
                      ? HistoryEmptyState(
                          icon: Icons.event_busy_rounded,
                          color: const Color(0xffF59E0B),
                          title: l10n.noDataInRange,
                          subtitle: l10n.addDiaperChangesHint,
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 32),
                          children: [
                            if (grouped[today] != null)
                              _summaryCard(l10n, grouped[today]!),
                            if (showTooltip) _swipeHint(l10n),
                            if (grouped[today] != null) ...[
                              HistorySectionTitle(
                                title: l10n.today,
                                count: grouped[today]!.length,
                                countLabel: l10n.diaperChanges.toLowerCase(),
                                color: const Color(0xffF59E0B),
                              ),
                              ...grouped[today]!.map(
                                (entry) => _entryPadding(entry, l10n),
                              ),
                            ],
                            for (final section in grouped.entries)
                              if (section.key != today)
                                _dayAccordion(
                                  day: section.key,
                                  dayEntries: section.value,
                                  l10n: l10n,
                                ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _filterBar(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(
              label: l10n.filter7d,
              value: _DiaperHistoryFilter.sevenDays,
            ),
            const SizedBox(width: 8),
            _filterChip(
              label: l10n.filter30d,
              value: _DiaperHistoryFilter.thirtyDays,
            ),
            const SizedBox(width: 8),
            _filterChip(label: l10n.filterAll, value: _DiaperHistoryFilter.all),
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: const Icon(Icons.calendar_month_rounded, size: 18),
              label: Text(_dateRangeLabel(l10n)),
              selected: _filter == _DiaperHistoryFilter.custom,
              onSelected: (_) => _pickDateRange(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required _DiaperHistoryFilter value,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) {
        setState(() {
          _filter = value;
          _customRange = null;
        });
      },
    );
  }

  String _dateRangeLabel(AppLocalizations l10n) {
    final range = _customRange;
    if (range == null) return l10n.selectDate;

    final start = AppDateFormatter.shortDate(context, range.start);
    if (AppDateUtils.isSameDay(range.start, range.end)) return start;
    return '$start – ${AppDateFormatter.shortDate(context, range.end)}';
  }

  Widget _dayAccordion({
    required DateTime day,
    required List<DiaperEntry> dayEntries,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;
    final peeCount = dayEntries
        .where(
          (entry) =>
              entry.type == DiaperType.pee || entry.type == DiaperType.both,
        )
        .length;
    final poopCount = dayEntries
        .where(
          (entry) =>
              entry.type == DiaperType.poop || entry.type == DiaperType.both,
        )
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 7, 16, 7),
      decoration: BoxDecoration(
        color: theme.cardColor.withAlpha(
          theme.brightness == Brightness.dark ? 220 : 248,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffF59E0B).withAlpha(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey('diaper-${day.toIso8601String()}'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xffF59E0B).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 19,
              color: Color(0xffF59E0B),
            ),
          ),
          title: Text(
            AppDateFormatter.sectionDate(context, day),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          subtitle: Text(
            l10n.diaperDaySummary(dayEntries.length, peeCount, poopCount),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.3,
              color: secondaryTextColor,
            ),
          ),
          children: [
            for (final entry in dayEntries) _entryPadding(entry, l10n),
          ],
        ),
      ),
    );
  }

  Widget _entryPadding(DiaperEntry entry, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: _modernItem(entry, l10n),
    );
  }

  Widget _summaryCard(AppLocalizations l10n, List<DiaperEntry> todayItems) {
    final peeCount = todayItems
        .where(
          (entry) =>
              entry.type == DiaperType.pee || entry.type == DiaperType.both,
        )
        .length;
    final poopCount = todayItems
        .where(
          (entry) =>
              entry.type == DiaperType.poop || entry.type == DiaperType.both,
        )
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffF59E0B), Color(0xffF97316)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffF59E0B).withAlpha(55),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryMetric(
              icon: Icons.today_rounded,
              value: todayItems.length.toString(),
              label: l10n.today,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryMetric(
              icon: Icons.invert_colors_rounded,
              value: peeCount.toString(),
              label: l10n.pee,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryMetric(
              icon: Icons.bubble_chart_rounded,
              value: poopCount.toString(),
              label: l10n.poop,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withAlpha(205),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _summaryDivider() => Container(
    width: 1,
    height: 54,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: Colors.white.withAlpha(45),
  );

  Widget _swipeHint(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => showTooltip = false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.swipe, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.swipeToDelete,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.swipeHintInfo,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.close, color: secondaryTextColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernItem(DiaperEntry entry, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;
    final mutedChipColor = isDark
        ? const Color(0xff2B2B2B)
        : Colors.grey.shade100;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => confirmHistoryDelete(context),
      onDismissed: (_) => deleteEntry(entry),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor.withAlpha(isDark ? 220 : 250),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _bgForType(entry.type).withAlpha(90)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 34 : 10),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _bgForType(entry.type),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: _icon(entry.type)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _titleFor(entry, l10n),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (entry.note != null && entry.note!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: mutedChipColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.note,
                            style: const TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _detailsFor(entry, l10n),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
                  '${entry.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.swipe_left_rounded,
                  color: secondaryTextColor,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _bgForType(DiaperType type) {
    switch (type) {
      case DiaperType.pee:
        return Colors.blue.withAlpha(31);
      case DiaperType.poop:
        return Colors.orange.withAlpha(31);
      case DiaperType.both:
        return Colors.purple.withAlpha(31);
    }
  }

  Widget _icon(DiaperType type) {
    switch (type) {
      case DiaperType.pee:
        return const Icon(Icons.invert_colors, color: Colors.blue);
      case DiaperType.poop:
        return const Icon(Icons.grass, color: Colors.orange);
      case DiaperType.both:
        return const Icon(Icons.bubble_chart, color: Colors.purple);
    }
  }

  String _titleFor(DiaperEntry entry, AppLocalizations l10n) {
    switch (entry.type) {
      case DiaperType.pee:
        return l10n.pee;
      case DiaperType.poop:
        return l10n.poop;
      case DiaperType.both:
        return l10n.peeAndPoop;
    }
  }

  String _detailsFor(DiaperEntry entry, AppLocalizations l10n) {
    final parts = <String>[];

    if (entry.peeAmount != null) {
      parts.add(
        '${l10n.peeAmountTitle}: '
        '${_labelForPeeAmount(entry.peeAmount!, l10n)}',
      );
    }
    if (entry.poopAmount != null) {
      parts.add(
        '${l10n.poopAmountTitle}: '
        '${_labelForPoopAmount(entry.poopAmount!, l10n)}',
      );
    }
    if (entry.poopColor != null) {
      parts.add('${l10n.color}: ${_labelForPoopColor(entry.poopColor!, l10n)}');
    }
    if (entry.note != null && entry.note!.isNotEmpty) {
      parts.add('"${entry.note!}"');
    }

    return parts.join(' - ');
  }

  String _labelForPeeAmount(PeeAmount amount, AppLocalizations l10n) {
    switch (amount) {
      case PeeAmount.small:
        return l10n.small;
      case PeeAmount.medium:
        return l10n.medium;
      case PeeAmount.large:
        return l10n.large;
    }
  }

  String _labelForPoopAmount(PoopAmount amount, AppLocalizations l10n) {
    switch (amount) {
      case PoopAmount.small:
        return l10n.small;
      case PoopAmount.medium:
        return l10n.medium;
      case PoopAmount.large:
        return l10n.large;
    }
  }

  String _labelForPoopColor(PoopColor color, AppLocalizations l10n) {
    switch (color) {
      case PoopColor.mustardYellow:
        return l10n.mustardYellow;
      case PoopColor.yellowGreen:
        return l10n.yellowGreen;
      case PoopColor.brown:
        return l10n.brown;
      case PoopColor.darkGreen:
        return l10n.darkGreen;
      case PoopColor.black:
        return l10n.black;
      case PoopColor.whiteGray:
        return l10n.whiteGray;
    }
  }

  Widget _emptyState(AppLocalizations l10n) {
    return HistoryEmptyState(
      icon: Icons.baby_changing_station_rounded,
      color: const Color(0xffF59E0B),
      title: l10n.noDiaperRecordsYet,
      subtitle: l10n.addDiaperChangesHint,
    );
  }
}
