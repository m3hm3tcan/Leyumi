import 'package:flutter/material.dart';
import 'package:babyfeedpro/services/feeding_storage.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';

import '../widgets/session_card.dart';
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

  Map<String, List<FeedingSession>> group() {
    final Map<String, List<FeedingSession>> map = {};

    for (final s in sessions) {
      final key = _getSection(s.startTime);
      map.putIfAbsent(key, () => []);
      map[key]!.add(s);
    }

    return map;
  }

  Future<void> deleteSession(FeedingSession session) async {
    setState(() {
        sessions.remove(session);
    });

    await FeedingStorage().saveAllSessions(sessions);
}

  String _getSection(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(date.year, date.month, date.day);

    if (sessionDay == today) return "Today";
    return "Older";
  }

  @override
  Widget build(BuildContext context) {
    final grouped = group();

    if (sessions.isEmpty) {
        return _emptyState();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 12),

        if (grouped["Today"] != null)
          TodaySummaryCard(sessions: grouped["Today"]!),

        for (final entry in grouped.entries)
          TimelineSection(
            title: entry.key,
            sessions: entry.value,
            onDelete: deleteSession,
          ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Icon(
                Icons.local_drink_outlined,
                size: 70,
                color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
                "No feeding records yet",
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                ),
            ),
            const SizedBox(height: 6),
            Text(
                "Start a feeding session to see your history here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                ),
            ),
            ],
        ),
        ),
    );
    }
}