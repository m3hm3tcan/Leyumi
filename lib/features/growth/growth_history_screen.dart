import 'package:flutter/material.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';
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

  Widget diff(num? diff, String unit) {
    if (diff == null) return const SizedBox();

    final isPositive = diff > 0;
    final color = isPositive ? Colors.green : Colors.red;
    final sign = isPositive ? "+" : "";

    return Text(
      " ($sign${diff.toStringAsFixed(0)} $unit)",
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: Text(l10n.growthHistoryTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (_, i) {
          final e = entries[i];

          // Bir önceki entry (fark hesaplamak için)
          GrowthEntry? prev = i < entries.length - 1 ? entries[i + 1] : null;

          // Ağırlık GR formatı
          final weightGr = e.weight;
          final prevWeightGr = prev?.weight;
          final weightDiff =
              prevWeightGr != null ? (weightGr - prevWeightGr) : null;

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

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------
              // TIMELINE (SOL)
              // -----------------------------
              Container(
                width: 40,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    // DOT
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                    ),

                    // ÇİZGİ (son elemana kadar)
                    if (i < entries.length - 1)
                      Container(
                        width: 2,
                        height: 80,
                        margin: const EdgeInsets.only(top: 4),
                        color: Colors.blueAccent.withAlpha(102),
                      ),
                  ],
                ),
              ),

              // -----------------------------
              // CARD (SAĞ)
              // -----------------------------
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 16, bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TARİH
                      Text(
                        formatDate(e.date),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          decoration: TextDecoration.none,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // AĞIRLIK
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$weightGr",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              l10n.unitGr,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          if (weightDiff != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 4),
                              child: diff(weightDiff, l10n.unitGr),
                            ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // METRİKLER (Boy, Kafa, Bel)
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _chip(l10n.height, "${e.height} ${l10n.unitCm}", heightDiff),
                          if (e.headCircumference != null)
                            _chip(l10n.headCircumference, "${e.headCircumference} ${l10n.unitCm}", headDiff),
                          if (e.waistCircumference != null)
                            _chip(l10n.waistCircumference, "${e.waistCircumference} ${l10n.unitCm}", waistDiff),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, String value, num? diffValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF4F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: $value",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (diffValue != null) ...[
            const SizedBox(width: 6),
            Text(
              "${diffValue > 0 ? "+" : ""}${diffValue.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 12,
                color: diffValue > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
