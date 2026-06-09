import 'package:flutter/material.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';
import 'package:babyfeedpro/models/growth_entry.dart';
import 'package:babyfeedpro/services/growth_storage.dart';

class GrowthTab extends StatefulWidget {
  const GrowthTab({super.key});

  @override
  State<GrowthTab> createState() => _GrowthTabState();
}

class _GrowthTabState extends State<GrowthTab> {
  List<GrowthEntry> entries = [];
  GrowthEntry? recentlyDeleted;
  int? recentlyDeletedIndex;

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

  Future<void> deleteEntry(GrowthEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final index = entries.indexOf(entry);

    setState(() {
      recentlyDeleted = entry;
      recentlyDeletedIndex = index;
      entries.removeAt(index);
    });

    await GrowthStorage().saveAllEntries(entries);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.entryDeleted),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            if (!mounted) return;
            if (recentlyDeleted != null && recentlyDeletedIndex != null) {
              setState(() {
                entries.insert(recentlyDeletedIndex!, recentlyDeleted!);
                recentlyDeleted = null;
                recentlyDeletedIndex = null;
              });
              await GrowthStorage().saveAllEntries(entries);
            }
          },
        ),
      ),
    );

    controller.closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        if (!mounted) return;
        setState(() {
          recentlyDeleted = null;
          recentlyDeletedIndex = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (entries.isEmpty) return _emptyState(context);

    return Container(
      color: const Color(0xffF6F7FB),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        itemCount: entries.length,
        itemBuilder: (context, i) {
          final e = entries[i];
          final prev = i < entries.length - 1 ? entries[i + 1] : null;

          final weight = e.weight.round();
          final prevWeight = prev?.weight.round();
          final weightDiff = prevWeight != null ? weight - prevWeight : null;

          final heightDiff = prev != null ? e.height - prev.height : null;

          final isLast = i == entries.length - 1;

          return Dismissible(
            key: ValueKey(e.date.toIso8601String()),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            ),
            onDismissed: (_) => deleteEntry(e),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TIMELINE
                SizedBox(
                  width: 50,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: isLast ? 40 : 80,
                        color: isLast ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),

                /// CARD
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16, bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// DATE
                        Text(
                          "${e.date.day.toString().padLeft(2, '0')}-"
                          "${e.date.month.toString().padLeft(2, '0')}-"
                          "${e.date.year}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// WEIGHT + DELTA
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "$weight",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
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
                                child: Text(
                                  "${weightDiff > 0 ? "+" : ""}$weightDiff ${l10n.unitGr}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: weightDiff > 0
                                        ? Colors.green
                                        : weightDiff < 0
                                            ? Colors.red
                                            : Colors.grey,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// HEIGHT + DELTA
                        _infoRow(
                          l10n.height,
                          "${e.height} ${l10n.unitCm}",
                          heightDiff,
                        ),

                        if (e.headCircumference != null)
                          _simpleRow(
                            l10n.headCircumference,
                            "${e.headCircumference} ${l10n.unitCm}",
                          ),

                        if (e.waistCircumference != null)
                          _simpleRow(
                            l10n.waistCircumference,
                            "${e.waistCircumference} ${l10n.unitCm}",
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          if (diff != null) ...[
            const SizedBox(width: 6),
            Text(
              "${diff > 0 ? "+" : ""}${diff.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: diff > 0
                    ? Colors.green
                    : diff < 0
                        ? Colors.red
                        : Colors.grey,
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

  Widget _emptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          l10n.noGrowthDataYet,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
