import 'package:flutter/material.dart';
import '../../services/feeding_storage.dart';
import '../feeding/feeding_session.dart';
import '../feeding/feeding_entry.dart';

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
    setState(() => sessions = data);
  }

  String format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);

    if (h > 0) return "${h}h ${m}m ${s}s";
    if (m > 0) return "${m}m ${s}s";
    return "${s}s";
  }

  String formatDate(DateTime dt) {
    return "${dt.day}.${dt.month}.${dt.year}  "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (_, i) {
          final session = sessions[i];

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 SESSION HEADER → DATE + TIME
                  Text(
                    formatDate(session.startTime),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🔥 TOTAL DURATION
                  Text(
                    "Toplam emzirme süresi: ${format(session.totalDuration)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔥 ENTRY LIST (side + duration + date)
                  ...session.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "${e.side.toUpperCase()} • ${format(e.duration)} • ${formatDate(session.startTime)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
