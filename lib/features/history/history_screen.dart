import 'package:flutter/material.dart';
import 'package:babyfeedpro/services/feeding_storage.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';

import 'widgets/session_card.dart';
import 'widgets/timeline_section.dart';
import 'widgets/today_summary_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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

  Map<String, List<FeedingSession>> groupSessions() {
    final Map<String, List<FeedingSession>> map = {};

    for (final s in sessions) {
      final key = _getSection(s.startTime);
      map.putIfAbsent(key, () => []);
      map[key]!.add(s);
    }

    return map;
  }

  String _getSection(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDay = DateTime(date.year, date.month, date.day);

    if (sessionDay == today) return "Today";
    if (sessionDay == yesterday) return "Yesterday";
    if (today.difference(sessionDay).inDays <= 7) return "This Week";

    return "Older";
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupSessions();

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),

        children: [
          const SizedBox(height: 12),

          /// 🌟 TODAY SUMMARY CARD (TOP PRIORITY)
          if (grouped["Today"] != null)
            TodaySummaryCard(sessions: grouped["Today"]!),

          /// TIMELINE SECTIONS
          for (final entry in grouped.entries)
            TimelineSection(
              title: entry.key,
              sessions: entry.value,
            ),
        ],
      ),
    );
  }
}