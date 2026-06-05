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

    return Container(
      color: const Color(0xffF6F7FB),
      child: sessions.isEmpty
          ? _emptyState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 12),

                /// TODAY SUMMARY (premium spacing)
                if (grouped["Today"] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TodaySummaryCard(sessions: grouped["Today"]!),
                  ),

                const SizedBox(height: 10),

                /// STREAM STYLE TIMELINE
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

  Widget _emptyState() {
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
                      color: Colors.black.withOpacity(0.05),
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

              const Text(
                "No feeding sessions yet",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Start a feeding session to track your baby's feeding history in a clean timeline.",
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