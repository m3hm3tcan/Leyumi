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
