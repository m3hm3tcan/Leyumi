import 'package:flutter/material.dart';
import '../../models/growth_entry.dart';
import '../../services/growth_storage.dart';

class GrowthHistoryScreen extends StatefulWidget {
  const GrowthHistoryScreen({super.key});

  @override
  State<GrowthHistoryScreen> createState() => _GrowthHistoryScreenState();
}

class _GrowthHistoryScreenState extends State<GrowthHistoryScreen> {
  List<GrowthEntry> entries = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await GrowthStorage().loadEntries();
    setState(() => entries = data);
  }

  String formatDate(DateTime dt) {
    return "${dt.day}.${dt.month}.${dt.year}  "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  Widget diffText(int? diff, String unit) {
    if (diff == null) return const SizedBox();

    final isPositive = diff > 0;
    final color = isPositive ? Colors.green : Colors.red;
    final sign = isPositive ? "+" : "";

    return Text(
      " ($sign${diff.toStringAsFixed(0)} $unit)",
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Growth History")),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (_, i) {
          final e = entries[i];

          // Bir önceki entry
          GrowthEntry? prev = i < entries.length - 1 ? entries[i + 1] : null;

          // Ağırlık GR formatına çevriliyor
          final weightGr = (e.weight * 1000).round();
          final prevWeightGr = prev != null ? (prev.weight * 1000).round() : null;
          final weightDiff = prevWeightGr != null ? (weightGr - prevWeightGr).toInt() : null;

          // Boy farkı
          final heightDiff = prev != null ? e.height - prev.height : null;

          // Baş çevresi farkı
          final headDiff = (prev != null &&
                  e.headCircumference != null &&
                  prev.headCircumference != null)
              ? e.headCircumference! - prev.headCircumference!
              : null;

          // Bel çevresi farkı
          final waistDiff = (prev != null &&
                  e.waistCircumference != null &&
                  prev.waistCircumference != null)
              ? e.waistCircumference! - prev.waistCircumference!
              : null;

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TARİH
                  Text(
                    formatDate(e.date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // KİLO (GR)
                  Row(
                    children: [
                      Text("Kilo: $weightGr gr"),
                      diffText(weightDiff, "gr"),
                    ],
                  ),

                  // BOY
                  Row(
                    children: [
                      Text("Boy: ${e.height} cm"),
                      diffText(heightDiff, "cm"),
                    ],
                  ),

                  // BAŞ ÇEVRESİ
                  if (e.headCircumference != null)
                    Row(
                      children: [
                        Text("Kafa çevresi: ${e.headCircumference} cm"),
                        diffText(headDiff, "cm"),
                      ],
                    ),

                  // BEL ÇEVRESİ
                  if (e.waistCircumference != null)
                    Row(
                      children: [
                        Text("Bel çevresi: ${e.waistCircumference} cm"),
                        diffText(waistDiff, "cm"),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
