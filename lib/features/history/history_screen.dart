import 'package:flutter/material.dart';
import '../../services/feeding_storage.dart';
import '../feeding/feeding_session.dart';

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
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text("Feeding History"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (_, i) {
          final session = sessions[i];

          // Sol toplam süre
          final leftTotal = session.entries
              .where((e) => e.side == "left")
              .fold(Duration.zero, (a, b) => a + b.duration);

          // Sağ toplam süre
          final rightTotal = session.entries
              .where((e) => e.side == "right")
              .fold(Duration.zero, (a, b) => a + b.duration);

          final startW = session.startWeightGr;
          final endW = session.endWeightGr;
          final diff = session.milkIntakeGr;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )
              ],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                collapsedBackgroundColor: Colors.white,
                backgroundColor: Colors.white,

                // -------------------------
                // HEADER (KAPALI HAL)
                // -------------------------
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDate(session.startTime),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Toplam süre: ${format(session.totalDuration)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                // -------------------------
                // EXPANDED CONTENT
                // -------------------------
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SOL / SAĞ TOPLAM SÜRELER
                        Text(
                          "Sol meme: ${format(leftTotal)}",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.pink.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Sağ meme: ${format(rightTotal)}",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // KİLO BİLGİLERİ
                        if (startW != null && endW != null) ...[
                          Divider(height: 22, color: Colors.grey.shade300),

                          Text(
                            "İlk kilo: $startW gr",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "Son kilo: $endW gr",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(height: 10),

                          // SADECE İÇİLEN SÜT MİKTARI
                          Text(
                            "İçilen süt: $diff gr",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
