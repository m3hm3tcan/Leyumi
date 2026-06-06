import 'package:flutter/material.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';
import 'package:babyfeedpro/services/feeding_storage.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  FeedingSession? recentlyDeleted;
  int? recentlyDeletedIndex;

  int tipCount = 0;
  bool showSwipeTip = true;

  @override
  void initState() {
    super.initState();
    load();
    loadTipState();
  }

  Future<void> load() async {
    final data = await FeedingStorage().loadSessions();
    data.sort((a, b) => b.startTime.compareTo(a.startTime));

    setState(() => sessions = data);
  }

  Map<String, List<FeedingSession>> groupSessions(AppLocalizations l10n) {
    final Map<String, List<FeedingSession>> map = {};

    for (final s in sessions) {
      final key = _getSection(s.startTime, l10n);
      map.putIfAbsent(key, () => []);
      map[key]!.add(s);
    }

    return map;
  }

  

  String _getSection(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDay = DateTime(date.year, date.month, date.day);

    if (sessionDay == today) return l10n.today;
    if (sessionDay == yesterday) return l10n.yesterday;
    if (today.difference(sessionDay).inDays <= 7) return l10n.thisWeek;

    return l10n.older;
  }

  Future<void> loadTipState() async {
    final prefs = await SharedPreferences.getInstance();

    final count =
        prefs.getInt("history_swipe_tip_count") ?? 0;

    await prefs.setInt(
      "history_swipe_tip_count",
      count + 1,
    );

    if (!mounted) return;

    setState(() {
      tipCount = count + 1;
      showSwipeTip = count < 3;
    });
  }

  Future<void> deleteSession(FeedingSession session) async {
    final index = sessions.indexOf(session);

    setState(() {
      recentlyDeleted = session;
      recentlyDeletedIndex = index;
      sessions.removeAt(index);
    });
    await FeedingStorage().saveAllSessions(sessions);

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.sessionDeleted),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            if (recentlyDeleted != null &&
                recentlyDeletedIndex != null) {
              setState(() {
                sessions.insert(
                  recentlyDeletedIndex!,
                  recentlyDeleted!,
                );
              });
              FeedingStorage().saveAllSessions(sessions);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final grouped = groupSessions(l10n);

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(
        title: Text(l10n.history),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),

        children: [
          const SizedBox(height: 12),

          /// 🌟 TODAY SUMMARY CARD (TOP PRIORITY)
          if (grouped[l10n.today] != null)
            TodaySummaryCard(sessions: grouped[l10n.today]!),

          if (showSwipeTip)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12,
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF4FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Color(0xff4DA3FF),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.swipeHistoryTip,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// TIMELINE SECTIONS
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
}