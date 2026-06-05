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

  Map<String, List<GrowthEntry>> _groupByDate(List<GrowthEntry> list) {
    final map = <String, List<GrowthEntry>>{};

    for (final e in list) {
      final key = formatDate(e.date);
      map.putIfAbsent(key, () => []);
      map[key]!.add(e);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _emptyState();

    final grouped = _groupByDate(entries);
    final keys = grouped.keys.toList();

    return Container(
      color: const Color(0xffF6F7FB),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: keys.length,
        itemBuilder: (context, i) {
          final dateKey = keys[i];
          final dayEntries = grouped[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// DATE HEADER
              Padding(
                padding: const EdgeInsets.only(
                    left: 56, top: 18, bottom: 8),
                child: Text(
                  dateKey,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),

              /// ITEMS
              ...List.generate(dayEntries.length, (index) {
                final e = dayEntries[index];
                final prev = index < dayEntries.length - 1
                    ? dayEntries[index + 1]
                    : null;

                final isLast = index == dayEntries.length - 1;

                /// WEIGHT
                final weight = e.weight.round();
                final prevWeight = prev?.weight.round();
                final weightDiff =
                    prevWeight != null ? weight - prevWeight : null;

                /// HEIGHT
                final heightDiff =
                    prev != null ? e.height - prev.height : null;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TIMELINE
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: isLast ? 60 : 110,
                            color: isLast
                                ? Colors.transparent
                                : Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),

                    /// CARD
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            right: 16, bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// WEIGHT + DELTA
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "$weight",
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    "g",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),

                                if (weightDiff != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 4),
                                    child: Text(
                                      "${weightDiff > 0 ? "+" : ""}$weightDiff g",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: weightDiff > 0
                                            ? Colors.green
                                            : Colors.red,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// HEIGHT + DELTA
                            _infoRow(
                              "Height",
                              "${e.height} cm",
                              heightDiff,
                            ),

                            if (e.headCircumference != null)
                              _simpleRow(
                                "Head",
                                "${e.headCircumference} cm",
                              ),

                            if (e.waistCircumference != null)
                              _simpleRow(
                                "Waist",
                                "${e.waistCircumference} cm",
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value, num? diff) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label: $value",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          if (diff != null) ...[
            const SizedBox(width: 6),
            Text(
              "${diff > 0 ? "+" : ""}${diff.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: diff > 0 ? Colors.green : Colors.red,
                decoration: TextDecoration.none,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _simpleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      color: const Color(0xffF6F7FB),
      child: const Center(
        child: Text(
          "No growth data yet",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}