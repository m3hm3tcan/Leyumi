import 'package:flutter/material.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';
import 'package:babyfeedpro/services/feeding_storage.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';

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
    setState(() => sessions = data);
  }

  Map<String, List<FeedingSession>> group(AppLocalizations l10n) {
    final Map<String, List<FeedingSession>> map = {};

    for (final s in sessions) {
      final key = _getSection(s.startTime, l10n);
      map.putIfAbsent(key, () => []);
      map[key]!.add(s);
    }

    return map;
  }

  String _getSection(
    DateTime date,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final sessionDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

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

    return Container(
      color: const Color(0xffF6F7FB),
      child: sessions.isEmpty
          ? _emptyState(l10n)
          : ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 12),

                /// TODAY SUMMARY (premium spacing)
                if (grouped[l10n.today] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TodaySummaryCard(sessions: grouped[l10n.today]!),
                  ),

                const SizedBox(height: 10),

                /// STREAM STYLE TIMELINE
                for (final entry in grouped.entries)
                  // if (entry.key != l10n.today)
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
    return Container(
      color: const Color(0xffF6F7FB),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
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
                  color: Colors.grey.shade600,
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