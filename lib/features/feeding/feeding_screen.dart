import 'package:flutter/material.dart';
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
  Duration elapsed = Duration.zero;
  String selectedSide = "left";
  bool isTiming = false;

  @override
  void initState() {
    super.initState();
    controller = FeedingController(
      onTick: (d) {
        setState(() => elapsed = d);
      },
    );
  }

  String format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);

    if (h > 0) return "${h}h ${m}m ${s}s";
    if (m > 0) return "${m}m ${s}s";
    return "${s}s";
  }

  @override
  Widget build(BuildContext context) {
    final session = controller.currentSession;

    return Scaffold(
      appBar: AppBar(title: const Text("Feeding Session")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // TIMER
            Text(
              format(elapsed),
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // SIDE SELECTOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Left"),
                  selected: selectedSide == "left",
                  onSelected: (_) {
                    if (!isTiming) {
                      setState(() => selectedSide = "left");
                    }
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Right"),
                  selected: selectedSide == "right",
                  onSelected: (_) {
                    if (!isTiming) {
                      setState(() => selectedSide = "right");
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // START / STOP BUTTON
            if (!isTiming)
              ElevatedButton(
                onPressed: () {
                  controller.startSide(selectedSide);
                  setState(() {
                    isTiming = true;
                    elapsed = Duration.zero;
                  });
                },
                child: const Text("Start"),
              )
            else
              ElevatedButton(
                onPressed: () {
                  final entry = controller.stopSide(selectedSide);

                  setState(() {
                    isTiming = false;
                    elapsed = Duration.zero;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${entry.side.toUpperCase()} kaydedildi • ${format(entry.duration)}",
                      ),
                    ),
                  );
                },
                child: const Text("Stop"),
              ),

            const SizedBox(height: 30),

            // LIVE LOG + TOTAL DURATION
            if (session != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOTAL DURATION
                    Text(
                      "Toplam emzirme süresi: ${format(session.totalDuration)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ENTRY LIST
                    ...session.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "${e.side.toUpperCase()} • ${format(e.duration)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // FINISH SESSION BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  final saved = controller.finishSession();
                  await FeedingStorage().saveSession(saved);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Session kaydedildi • ${format(saved.totalDuration)}",
                      ),
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Finish Session"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
