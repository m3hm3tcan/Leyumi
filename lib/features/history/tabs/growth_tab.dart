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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isUp ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "${isUp ? "+" : ""}${diff.toStringAsFixed(0)} $unit",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isUp ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (entries.isEmpty) {
        return _emptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
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
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(e.date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              // WEIGHT
              Row(
                children: [
                  Text("Weight: ${weightGr}g"),
                  const SizedBox(width: 8),
                  diffChip(weightDiff, "g"),
                ],
              ),

              const SizedBox(height: 6),

              // HEIGHT
              Row(
                children: [
                  Text("Height: ${e.height} cm"),
                  const SizedBox(width: 8),
                  diffChip(heightDiff, "cm"),
                ],
              ),

              const SizedBox(height: 6),

              if (e.headCircumference != null)
                Text("Head: ${e.headCircumference} cm"),

              if (e.waistCircumference != null)
                Text("Waist: ${e.waistCircumference} cm"),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Icon(
                Icons.show_chart_outlined,
                size: 70,
                color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
                "No growth records yet",
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                ),
            ),
            const SizedBox(height: 6),
            Text(
                "Add your baby's weight and measurements to track progress.",
                textAlign: TextAlign.center,
                style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                ),
            ),
            ],
        ),
        ),
    );
    }
}