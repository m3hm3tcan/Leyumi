import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'feeding_controller.dart';
import 'feeding_session.dart';
import 'feeding_entry.dart';
import '../../services/feeding_storage.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  late FeedingController controller;

  Duration currentTimer = Duration.zero;
  String? activeSide;

  final startWeightCtrl = TextEditingController();
  final endWeightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = FeedingController(onTick: (d) {
      setState(() => currentTimer = d);
    });
  }

  String formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void startFeeding(String side) {
    if (controller.currentSession == null) {
      // Feeding öncesi kilo
      if (startWeightCtrl.text.isNotEmpty) {
        controller.setStartWeight(int.parse(startWeightCtrl.text));
      }
    }

    setState(() {
      activeSide = side;
      currentTimer = Duration.zero;
    });

    controller.startSide(side);
  }

  void stopFeeding() {
    if (activeSide == null) return;

    controller.stopSide(activeSide!);

    setState(() {
      activeSide = null;
      currentTimer = Duration.zero;
    });
  }

  void finishSession() async {
    // Feeding sonrası kilo
    if (endWeightCtrl.text.isNotEmpty) {
      controller.setEndWeight(int.parse(endWeightCtrl.text));
    }

    final session = controller.finishSession();
    await FeedingStorage().saveSession(session);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget buildEntryCard(FeedingEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            entry.side == "left" ? Icons.arrow_back : Icons.arrow_forward,
            color: entry.side == "left" ? Colors.pink : Colors.blue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            entry.side == "left" ? "Sol Meme" : "Sağ Meme",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            formatTime(entry.duration),
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = controller.currentSession?.entries ?? [];

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text("Feeding Session"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // -----------------------------
            // FEEDING ÖNCESİ KİLO GİRİŞİ
            // -----------------------------
            if (controller.currentSession == null) ...[
              Text(
                "Bebeğin Kilosu (gr)",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: startWeightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Örn: 2500",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // -----------------------------
            // TIMER
            // -----------------------------
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    formatTime(currentTimer),
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activeSide == null
                        ? "Hazır"
                        : (activeSide == "left" ? "Sol Meme" : "Sağ Meme"),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // -----------------------------
            // SOL / SAĞ BUTONLARI
            // -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // SOL
                GestureDetector(
                  onTap: activeSide == null ? () => startFeeding("left") : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: activeSide == "left"
                          ? Colors.pink.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.arrow_back,
                            size: 40, color: Colors.pink.shade400),
                        const SizedBox(height: 8),
                        Text("Sol",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),

                // SAĞ
                GestureDetector(
                  onTap: activeSide == null ? () => startFeeding("right") : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: activeSide == "right"
                          ? Colors.blue.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.arrow_forward,
                            size: 40, color: Colors.blue.shade400),
                        const SizedBox(height: 8),
                        Text("Sağ",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // STOP BUTTON
            if (activeSide != null)
              ElevatedButton(
                onPressed: stopFeeding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  "Durdur",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),

            const SizedBox(height: 30),

            // -----------------------------
            // ENTRY LOG
            // -----------------------------
            if (entries.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Kayıtlar",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              ...entries.map((e) => buildEntryCard(e as FeedingEntry)),
            ],

            const SizedBox(height: 30),

            // -----------------------------
            // FINISH SESSION
            // -----------------------------
            if (entries.isNotEmpty && activeSide == null) ...[
              Text(
                "Feeding Sonrası Kilo (gr)",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: endWeightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Örn: 2550",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: finishSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  "Kaydet",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
