import 'package:flutter/material.dart';
import 'package:babyfeedpro/models/growth_entry.dart';
import 'package:babyfeedpro/services/growth_storage.dart';

class GrowthTab extends StatefulWidget {
  const GrowthTab({super.key});

  @override
  State<GrowthTab> createState() => _GrowthTabState();
}

class _GrowthTabState extends State<GrowthTab> {
  List<GrowthEntry> entries = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await GrowthStorage().loadEntries();
    data.sort((a, b) => b.date.compareTo(a.date));
    setState(() => entries = data);
  }

  String formatDate(DateTime dt) {
    return "${dt.day}.${dt.month}.${dt.year}";
  }

  Widget diffChip(int? diff, String unit) {
    if (diff == null) return const SizedBox();

    final isUp = diff > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isUp ? Colors.green : Colors.red).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "${isUp ? "+" : ""}${diff.toStringAsFixed(0)} $unit",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isUp ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _emptyState();
    }

    return Container(
      color: const Color(0xffF6F7FB),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final e = entries[i];
          final prev = i < entries.length - 1 ? entries[i + 1] : null;

          final weightGr = (e.weight * 1000).round();
          final prevWeightGr =
              prev != null ? (prev.weight * 1000).round() : null;

          final weightDiff =
              prevWeightGr != null ? weightGr - prevWeightGr : null;

          final heightDiff =
              prev != null ? (e.height - prev.height) : null;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DATE
                Text(
                  formatDate(e.date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 12),

                /// WEIGHT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${weightGr}g",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    diffChip(weightDiff, "g"),
                  ],
                ),

                const SizedBox(height: 10),

                /// HEIGHT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${e.height} cm",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    diffChip(heightDiff, "cm"),
                  ],
                ),

                const SizedBox(height: 10),

                /// EXTRA METRICS (clean grid feel)
                if (e.headCircumference != null ||
                    e.waistCircumference != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (e.headCircumference != null)
                        _metric("Head", "${e.headCircumference} cm"),

                      if (e.waistCircumference != null)
                        _metric("Waist", "${e.waistCircumference} cm"),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF6F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
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
                  Icons.show_chart_rounded,
                  size: 60,
                  color: Colors.blueGrey,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "No growth data yet",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Track your baby's growth over time to see progress clearly.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}