import 'package:flutter/material.dart';
import 'package:leyumi/features/history/helpers/delete_confirmation.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/models/growth_entry.dart';
import 'package:leyumi/services/growth_storage.dart';

import '../../../core/child/active_child_aware.dart';
import '../widgets/history_page_shell.dart';

class GrowthTab extends StatefulWidget {
  const GrowthTab({super.key});

  @override
  State<GrowthTab> createState() => _GrowthTabState();
}

class _GrowthTabState extends State<GrowthTab>
    with ActiveChildAware<GrowthTab> {
  List<GrowthEntry> entries = [];
  GrowthEntry? recentlyDeleted;
  int? recentlyDeletedIndex;

  Future<void> load() async {
    final data = await GrowthStorage().loadEntries();
    data.sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() => entries = data);
  }

  @override
  Future<void> onActiveChildChanged() => load();

  Future<void> deleteEntry(GrowthEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final index = entries.indexOf(entry);

    setState(() {
      recentlyDeleted = entry;
      recentlyDeletedIndex = index;
      entries.removeAt(index);
    });

    await GrowthStorage().saveAllEntries(entries);

    final messenger = ScaffoldMessenger.of(context);
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
              setState(() {
                entries.insert(recentlyDeletedIndex!, recentlyDeleted!);
                recentlyDeleted = null;
                recentlyDeletedIndex = null;
              });
              await GrowthStorage().saveAllEntries(entries);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return HistoryPageShell(
      title: l10n.growth,
      subtitle: l10n.growthMeasurements,
      icon: Icons.monitor_weight_rounded,
      color: const Color(0xff22C55E),
      showHeader: false,
      child: entries.isEmpty
          ? _emptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _latestSummaryCard(l10n);

                final entryIndex = index - 1;
                final entry = entries[entryIndex];
                final prev = entryIndex < entries.length - 1
                    ? entries[entryIndex + 1]
                    : null;
                final weight = entry.weight.round();
                final prevWeight = prev?.weight.round();
                final weightDiff = prevWeight != null
                    ? weight - prevWeight
                    : null;
                final heightDiff = prev != null
                    ? entry.height - prev.height
                    : null;
                final isLast = entryIndex == entries.length - 1;

                return _growthTimelineItem(
                  entry: entry,
                  isLast: isLast,
                  weight: weight,
                  weightDiff: weightDiff,
                  heightDiff: heightDiff,
                  l10n: l10n,
                );
              },
            ),
    );
  }

  Widget _latestSummaryCard(AppLocalizations l10n) {
    final latest = entries.first;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff22C55E), Color(0xff14B8A6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff22C55E).withAlpha(55),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.latestMeasurement,
                style: TextStyle(
                  color: Colors.white.withAlpha(220),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _growthMetric(
                  label: l10n.weight,
                  value: '${latest.weight.round()} ${l10n.unitGr}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _growthMetric(
                  label: l10n.height,
                  value: '${latest.height} ${l10n.unitCm}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _growthMetric(
                  label: l10n.history,
                  value: entries.length.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            MaterialLocalizations.of(context).formatMediumDate(latest.date),
            style: TextStyle(
              color: Colors.white.withAlpha(190),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthTimelineItem({
    required GrowthEntry entry,
    required bool isLast,
    required int weight,
    required int? weightDiff,
    required num? heightDiff,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.fromLTRB(50, 6, 16, 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => confirmHistoryDelete(context),
      onDismissed: (_) => deleteEntry(entry),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xff22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.cardColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff22C55E).withAlpha(70),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2,
                  height: isLast ? 42 : 102,
                  margin: const EdgeInsets.only(top: 4),
                  color: isLast
                      ? Colors.transparent
                      : const Color(0xff22C55E).withAlpha(45),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 16, bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.cardColor.withAlpha(isDark ? 220 : 250),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xff22C55E).withAlpha(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 38 : 10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(entry.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.swipe_left_rounded,
                        color: secondaryTextColor,
                        size: 19,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$weight',
                        style: const TextStyle(
                          fontSize: 34,
                          height: .95,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l10n.unitGr,
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      if (weightDiff != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 5),
                          child: _diffPill(
                            '${weightDiff > 0 ? "+" : ""}'
                            '$weightDiff ${l10n.unitGr}',
                            weightDiff,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    context,
                    l10n.height,
                    '${entry.height} ${l10n.unitCm}',
                    heightDiff,
                  ),
                  if (entry.headCircumference != null)
                    _simpleRow(
                      context,
                      l10n.headCircumference,
                      '${entry.headCircumference} ${l10n.unitCm}',
                    ),
                  if (entry.waistCircumference != null)
                    _simpleRow(
                      context,
                      l10n.waistCircumference,
                      '${entry.waistCircumference} ${l10n.unitCm}',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthMetric({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(190),
              fontSize: 10,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _diffPill(String label, num diff) {
    final color = diff > 0
        ? const Color(0xff16A34A)
        : diff < 0
        ? Colors.red
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: color,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value, num? diff) {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170) ??
        Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Flexible(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          if (diff != null) ...[
            const SizedBox(width: 6),
            Text(
              '${diff > 0 ? "+" : ""}${diff.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: diff > 0
                    ? const Color(0xff16A34A)
                    : diff < 0
                    ? Colors.red
                    : secondaryTextColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _simpleRow(BuildContext context, String label, String value) {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170) ??
        Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 13,
          color: secondaryTextColor,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return HistoryEmptyState(
      icon: Icons.monitor_weight_rounded,
      color: const Color(0xff22C55E),
      title: l10n.noGrowthDataYet,
      subtitle: l10n.growthMeasurements,
    );
  }
}
