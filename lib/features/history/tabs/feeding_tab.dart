import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/services/feeding_storage.dart';
import 'package:flutter/material.dart';

import '../../../core/child/active_child_aware.dart';
import '../../../core/utils/app_date_utils.dart';
import '../widgets/history_page_shell.dart';
import '../widgets/timeline_section.dart';
import '../widgets/today_summary_card.dart';

enum _FeedingHistoryFilter { sevenDays, thirtyDays, all, custom }

class FeedingTab extends StatefulWidget {
  const FeedingTab({super.key});

  @override
  State<FeedingTab> createState() => _FeedingTabState();
}

class _FeedingTabState extends State<FeedingTab>
    with ActiveChildAware<FeedingTab> {
  List<FeedingSession> sessions = [];
  _FeedingHistoryFilter _filter = _FeedingHistoryFilter.sevenDays;
  DateTimeRange? _customRange;

  Future<void> load() async {
    final data = await FeedingStorage().loadSessions();
    data.sort((a, b) => b.startTime.compareTo(a.startTime));
    if (!mounted) return;
    setState(() => sessions = data);
  }

  @override
  Future<void> onActiveChildChanged() => load();

  List<FeedingSession> get _filteredSessions {
    if (_filter == _FeedingHistoryFilter.all) return sessions;

    late final DateTime start;
    late final DateTime endExclusive;
    if (_filter == _FeedingHistoryFilter.custom && _customRange != null) {
      start = AppDateUtils.dateOnly(_customRange!.start);
      endExclusive = AppDateUtils.dateOnly(
        _customRange!.end,
      ).add(const Duration(days: 1));
    } else {
      final days = _filter == _FeedingHistoryFilter.sevenDays ? 7 : 30;
      start = AppDateUtils.startOfRange(days);
      endExclusive = AppDateUtils.dateOnly(
        DateTime.now(),
      ).add(const Duration(days: 1));
    }

    return sessions
        .where(
          (session) =>
              !session.startTime.isBefore(start) &&
              session.startTime.isBefore(endExclusive),
        )
        .toList(growable: false);
  }

  Map<DateTime, List<FeedingSession>> group(List<FeedingSession> source) {
    final map = <DateTime, List<FeedingSession>>{};

    for (final session in source) {
      final key = AppDateUtils.dateOnly(session.startTime);
      map.putIfAbsent(key, () => []);
      map[key]!.add(session);
    }

    return map;
  }

  Future<void> _pickDateRange() async {
    if (sessions.isEmpty) return;

    final today = AppDateUtils.dateOnly(DateTime.now());
    final oldest = AppDateUtils.dateOnly(sessions.last.startTime);
    final defaultStart = AppDateUtils.startOfRange(30).isBefore(oldest)
        ? oldest
        : AppDateUtils.startOfRange(30);
    final initialRange =
        _customRange ?? DateTimeRange(start: defaultStart, end: today);
    final selected = await showDateRangePicker(
      context: context,
      firstDate: oldest,
      lastDate: today,
      initialDateRange: initialRange,
    );
    if (selected == null || !mounted) return;

    setState(() {
      _customRange = DateTimeRange(
        start: AppDateUtils.dateOnly(selected.start),
        end: AppDateUtils.dateOnly(selected.end),
      );
      _filter = _FeedingHistoryFilter.custom;
    });
  }

  Future<void> deleteSession(FeedingSession session) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final index = sessions.indexOf(session);
    setState(() {
      sessions.remove(session);
    });

    try {
      await FeedingStorage().saveAllSessions(sessions);
    } catch (_) {
      if (!mounted) return;
      setState(() => sessions.insert(index, session));
      messenger.showSnackBar(SnackBar(content: Text(l10n.operationFailed)));
    }
  }

  Future<void> editSession(FeedingSession session) async {
    if (!AppDateUtils.isToday(session.startTime)) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final range = await _showEditDialog(session);
    if (range == null) return;

    final updated = _copyWithTimeRange(
      session,
      startTime: range.$1,
      endTime: range.$2,
    );

    final index = sessions.indexWhere((item) => item.id == session.id);
    if (index == -1) return;
    setState(() {
      sessions[index] = updated;
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    });

    try {
      await FeedingStorage().saveAllSessions(sessions);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final updatedIndex = sessions.indexWhere(
          (item) => item.id == session.id,
        );
        if (updatedIndex != -1) sessions[updatedIndex] = session;
        sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.operationFailed)));
    }
  }

  FeedingSession _copyWithTimeRange(
    FeedingSession session, {
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final newDuration = endTime.difference(startTime);
    final oldTotalSeconds = session.totalDuration.inSeconds;
    final leftRatio = oldTotalSeconds <= 0 ? .5 : session.leftRatio;
    final leftSeconds = (newDuration.inSeconds * leftRatio).round();
    final rightSeconds = newDuration.inSeconds - leftSeconds;

    return FeedingSession(
      id: session.id,
      childId: session.childId,
      startTime: startTime,
      endTime: endTime,
      entries: [
        FeedingEntry(
          side: FeedingSide.left,
          duration: Duration(seconds: leftSeconds),
        ),
        FeedingEntry(
          side: FeedingSide.right,
          duration: Duration(seconds: rightSeconds),
        ),
      ],
      startWeightGr: session.startWeightGr,
      endWeightGr: session.endWeightGr,
      milkIntakeGr: session.milkIntakeGr,
      createdAt: session.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<(DateTime, DateTime)?> _showEditDialog(FeedingSession session) async {
    final l10n = AppLocalizations.of(context);
    final baseDate = AppDateUtils.dateOnly(session.startTime);
    var start = TimeOfDay.fromDateTime(session.startTime);
    var end = TimeOfDay.fromDateTime(session.endTime);
    String? error;

    (DateTime, DateTime) buildRange() {
      final startDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        start.hour,
        start.minute,
      );
      var endDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        end.hour,
        end.minute,
      );
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(const Duration(days: 1));
      }
      return (startDateTime, endDateTime);
    }

    return showDialog<(DateTime, DateTime)>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickStart() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: start,
              );
              if (picked == null) return;
              setDialogState(() {
                start = picked;
                error = null;
              });
            }

            Future<void> pickEnd() async {
              final picked = await showTimePicker(
                context: context,
                initialTime: end,
              );
              if (picked == null) return;
              setDialogState(() {
                end = picked;
                error = null;
              });
            }

            void save() {
              final range = buildRange();
              final duration = range.$2.difference(range.$1);
              final now = DateTime.now();

              if (!range.$2.isAfter(range.$1) || duration == Duration.zero) {
                setDialogState(() => error = l10n.feedingTimeOrderError);
                return;
              }
              if (duration > const Duration(hours: 12)) {
                setDialogState(() => error = l10n.feedingDurationRangeError);
                return;
              }
              if (range.$1.isAfter(now) || range.$2.isAfter(now)) {
                setDialogState(() => error = l10n.futureDateTimeError);
                return;
              }

              Navigator.of(dialogContext).pop(range);
            }

            return AlertDialog(
              title: Text('${l10n.edit} ${l10n.feeding}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _editTimeTile(
                    label: l10n.startTime,
                    value: start,
                    onTap: pickStart,
                    hasError: error != null,
                  ),
                  const SizedBox(height: 10),
                  _editTimeTile(
                    label: l10n.endTime,
                    value: end,
                    onTap: pickEnd,
                    hasError: error != null,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(onPressed: save, child: Text(l10n.saveChanges)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _editTimeTile({
    required String label,
    required TimeOfDay value,
    required VoidCallback onTap,
    required bool hasError,
  }) {
    final errorColor = Theme.of(context).colorScheme.error;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: hasError ? errorColor.withAlpha(12) : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? errorColor : Theme.of(context).dividerColor,
          width: hasError ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.schedule_rounded,
          color: hasError ? errorColor : null,
        ),
        title: Text(label),
        trailing: Text(
          MaterialLocalizations.of(context).formatTimeOfDay(value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filteredSessions;
    final grouped = group(filtered);
    final today = AppDateUtils.dateOnly(DateTime.now());

    return HistoryPageShell(
      title: l10n.feeding,
      subtitle: l10n.startFeedingSessionHint,
      icon: Icons.local_drink_rounded,
      color: const Color(0xff4DA3FF),
      showHeader: false,
      child: sessions.isEmpty
          ? _emptyState(l10n)
          : Column(
              children: [
                _filterBar(l10n),
                Expanded(
                  child: filtered.isEmpty
                      ? HistoryEmptyState(
                          icon: Icons.event_busy_rounded,
                          color: const Color(0xff4DA3FF),
                          title: l10n.noDataInRange,
                          subtitle: l10n.startFeedingSessionHint,
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 32),
                          children: [
                            if (grouped[today] != null)
                              TodaySummaryCard(sessions: grouped[today]!),
                            if (grouped[today] != null)
                              TimelineSection(
                                key: const ValueKey('feeding-today'),
                                title: l10n.today,
                                sessions: grouped[today]!,
                                summary: _dailySummary(grouped[today]!, l10n),
                                onDelete: deleteSession,
                                onEdit: editSession,
                              ),
                            for (final entry in grouped.entries)
                              if (entry.key != today)
                                TimelineSection(
                                  key: ValueKey(
                                    'feeding-${entry.key.toIso8601String()}',
                                  ),
                                  title: AppDateFormatter.sectionDate(
                                    context,
                                    entry.key,
                                  ),
                                  sessions: entry.value,
                                  summary: _dailySummary(entry.value, l10n),
                                  collapsible: true,
                                  onDelete: deleteSession,
                                  onEdit: editSession,
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
              value: _FeedingHistoryFilter.sevenDays,
            ),
            const SizedBox(width: 8),
            _filterChip(
              label: l10n.filter30d,
              value: _FeedingHistoryFilter.thirtyDays,
            ),
            const SizedBox(width: 8),
            _filterChip(
              label: l10n.filterAll,
              value: _FeedingHistoryFilter.all,
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: const Icon(Icons.calendar_month_rounded, size: 18),
              label: Text(_dateRangeLabel(l10n)),
              selected: _filter == _FeedingHistoryFilter.custom,
              onSelected: (_) => _pickDateRange(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required _FeedingHistoryFilter value,
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

  String _dailySummary(
    List<FeedingSession> daySessions,
    AppLocalizations l10n,
  ) {
    final duration = daySessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + session.totalDuration,
    );
    final milk = daySessions.fold<int>(
      0,
      (total, session) => total + session.totalMilkIntake,
    );
    final durationText = _compactDuration(duration, l10n);
    final parts = <String>[
      '${daySessions.length} ${l10n.sessions.toLowerCase()}',
      durationText,
      if (milk > 0) '$milk ${l10n.unitGr} ${l10n.milk.toLowerCase()}',
    ];
    return parts.join(' · ');
  }

  String _compactDuration(Duration duration, AppLocalizations l10n) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours ${l10n.hoursShort} $minutes ${l10n.minutesShort}';
    }
    return '${duration.inMinutes} ${l10n.minutesShort}';
  }

  Widget _emptyState(AppLocalizations l10n) {
    return HistoryEmptyState(
      icon: Icons.local_drink_outlined,
      color: const Color(0xff4DA3FF),
      title: l10n.noFeedingSessionsYet,
      subtitle: l10n.startFeedingSessionHint,
    );
  }
}
