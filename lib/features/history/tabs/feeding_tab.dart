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

class FeedingTab extends StatefulWidget {
  const FeedingTab({super.key});

  @override
  State<FeedingTab> createState() => _FeedingTabState();
}

class _FeedingTabState extends State<FeedingTab>
    with ActiveChildAware<FeedingTab> {
  List<FeedingSession> sessions = [];

  Future<void> load() async {
    final data = await FeedingStorage().loadSessions();
    data.sort((a, b) => b.startTime.compareTo(a.startTime));
    if (!mounted) return;
    setState(() => sessions = data);
  }

  @override
  Future<void> onActiveChildChanged() => load();

  Map<String, List<FeedingSession>> group(AppLocalizations l10n) {
    final map = <String, List<FeedingSession>>{};

    for (final session in sessions) {
      final key = _getSection(session.startTime, l10n);
      map.putIfAbsent(key, () => []);
      map[key]!.add(session);
    }

    return map;
  }

  String _getSection(DateTime date, AppLocalizations l10n) {
    if (AppDateUtils.isToday(date)) {
      return l10n.today;
    }

    return AppDateFormatter.sectionDate(context, date);
  }

  Future<void> deleteSession(FeedingSession session) async {
    setState(() {
      sessions.remove(session);
    });

    await FeedingStorage().saveAllSessions(sessions);
  }

  Future<void> editSession(FeedingSession session) async {
    if (!AppDateUtils.isToday(session.startTime)) return;

    final range = await _showEditDialog(session);
    if (range == null) return;

    final updated = _copyWithTimeRange(
      session,
      startTime: range.$1,
      endTime: range.$2,
    );

    setState(() {
      final index = sessions.indexWhere((item) => item.id == session.id);
      if (index == -1) return;
      sessions[index] = updated;
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    });

    await FeedingStorage().saveAllSessions(sessions);
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
    final grouped = group(l10n);

    return HistoryPageShell(
      title: l10n.feeding,
      subtitle: l10n.startFeedingSessionHint,
      icon: Icons.local_drink_rounded,
      color: const Color(0xff4DA3FF),
      showHeader: false,
      child: sessions.isEmpty
          ? _emptyState(l10n)
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (grouped[l10n.today] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TodaySummaryCard(sessions: grouped[l10n.today]!),
                  ),
                const SizedBox(height: 10),
                for (final entry in grouped.entries)
                  TimelineSection(
                    title: entry.key,
                    sessions: entry.value,
                    onDelete: deleteSession,
                    onEdit: editSession,
                  ),
              ],
            ),
    );
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
