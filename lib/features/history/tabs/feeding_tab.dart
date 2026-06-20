import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/services/feeding_storage.dart';
import 'package:flutter/material.dart';

import '../widgets/timeline_section.dart';
import '../widgets/today_summary_card.dart';

class FeedingTab extends StatefulWidget {
  const FeedingTab({super.key});

  @override
  State<FeedingTab> createState() => _FeedingTabState();
}

class _FeedingTabState extends State<FeedingTab> {
  List<FeedingSession> sessions = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await FeedingStorage().loadSessions();
    data.sort((a, b) => b.startTime.compareTo(a.startTime));
    if (!mounted) return;
    setState(() => sessions = data);
  }

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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(date.year, date.month, date.day);

    if (sessionDay == today) {
      return l10n.today;
    }

    return _formatSectionDate(sessionDay);
  }

  String _formatSectionDate(DateTime date) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return "${months[date.month]} ${date.day}, ${date.year}";
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

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: sessions.isEmpty
          ? _emptyState(l10n)
          : ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 12),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 35 : 13),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_drink_outlined,
                  size: 60,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.noFeedingSessionsYet,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.startFeedingSessionHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
