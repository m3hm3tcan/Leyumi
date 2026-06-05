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
  FeedingSide? activeSide;

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

  void startFeeding(FeedingSide side) {
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

  // Widget buildEntryCard(FeedingEntry entry) {
  //   final isLeft = entry.side == FeedingSide.left;

  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 6),
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.85),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         )
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           isLeft ? Icons.arrow_back : Icons.arrow_forward,
  //           color: isLeft ? Colors.pink : Colors.blue,
  //           size: 28,
  //         ),
  //         const SizedBox(width: 12),
  //         Text(
  //           isLeft ? "Sol Meme" : "Sağ Meme",
  //           style: GoogleFonts.poppins(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         const Spacer(),
  //         Text(
  //           formatTime(entry.duration),
  //           style: GoogleFonts.poppins(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.none,),
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 28,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff4DA3FF),
                    Color(0xff7CC5FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff4DA3FF),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: activeSide != null
                              ? Colors.greenAccent
                              : Colors.white70,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        activeSide != null
                            ? "LIVE SESSION"
                            : "READY",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    formatTime(currentTimer),
                    style: GoogleFonts.poppins(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    activeSide == null
                        ? "Tap left or right to start"
                        : activeSide == FeedingSide.left
                            ? "LEFT SIDE"
                            : "RIGHT SIDE",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: activeSide == null
                        ? () => startFeeding(FeedingSide.left)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 145,
                      decoration: BoxDecoration(
                        color: activeSide == FeedingSide.left
                            ? const Color(0xffFFE4EF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: activeSide == FeedingSide.left
                              ? Colors.pink
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.pink,
                            size: 34,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "LEFT",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "${controller.currentSession?.leftDuration.inMinutes ?? 0}m",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          if (activeSide == FeedingSide.left)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "LIVE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: GestureDetector(
                    onTap: activeSide == null
                        ? () => startFeeding(FeedingSide.right)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 145,
                      decoration: BoxDecoration(
                        color: activeSide == FeedingSide.right
                            ? const Color(0xffE9F5FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: activeSide == FeedingSide.right
                              ? const Color(0xff4DA3FF)
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Color(0xff4DA3FF),
                            size: 34,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "RIGHT",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "${controller.currentSession?.rightDuration.inMinutes ?? 0}m",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          if (activeSide == FeedingSide.right)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xff4DA3FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "LIVE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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
               buildSimpleSummary(entries),
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

  Widget buildSimpleSummary(List<FeedingEntry> entries) {
    Duration left = Duration.zero;
    Duration right = Duration.zero;

    for (final e in entries) {
      if (e.side == FeedingSide.left) {
        left += e.duration;
      } else {
        right += e.duration;
      }
    }

    final total = left + right;

    final leftPct =
        total.inSeconds == 0 ? 0.5 : left.inSeconds / total.inSeconds;

    final rightPct =
        total.inSeconds == 0 ? 0.5 : right.inSeconds / total.inSeconds;

    String fmt(Duration d) =>
        "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Feeding Özeti",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          // PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  flex: (leftPct * 1000).toInt(),
                  child: Container(
                    height: 12,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  flex: (rightPct * 1000).toInt(),
                  child: Container(
                    height: 12,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sol",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "${(leftPct * 100).toStringAsFixed(0)}%",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  Text(
                    fmt(left),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Sağ",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.pink,
                    ),
                  ),
                  Text(
                    "${(rightPct * 100).toStringAsFixed(0)}%",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  Text(
                    fmt(right),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              "Toplam: ${fmt(total)}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
