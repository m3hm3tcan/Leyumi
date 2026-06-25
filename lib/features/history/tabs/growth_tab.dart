import 'package:leyumi/features/history/helpers/delete_confirmation.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/models/growth_entry.dart';
import 'package:leyumi/services/growth_storage.dart';
import 'package:flutter/material.dart';

import '../../../core/child/active_child_aware.dart';

class GrowthTab extends StatefulWidget {
  const GrowthTab({super.key});

  @override
  State<GrowthTab> createState() => _GrowthTabState();
}

class _GrowthTabState extends State<GrowthTab>
    with ActiveChildAware<GrowthTab> {
  List<GrowthEntry> entries = [];
  GrowthEntry? recentlyDeleted;
  int? recentlyDeletedIndex;

  Future<void> load() async {
    final data = await GrowthStorage().loadEntries();
    data.sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() => entries = data);
  }

  @override
  Future<void> onActiveChildChanged() => load();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    if (entries.isEmpty) {
      return _emptyState(context);
    }

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final prev = index < entries.length - 1 ? entries[index + 1] : null;
          final weight = entry.weight.round();
          final prevWeight = prev?.weight.round();
          final weightDiff = prevWeight != null ? weight - prevWeight : null;
          final heightDiff = prev != null ? entry.height - prev.height : null;
          final isLast = index == entries.length - 1;

          return Dismissible(
            key: ValueKey(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            confirmDismiss: (_) => confirmHistoryDelete(context),
            onDismissed: (_) => deleteEntry(entry),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        color: isLast
                            ? Colors.transparent
                            : secondaryTextColor.withAlpha(60),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16, bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 35 : 13),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${entry.date.day.toString().padLeft(2, '0')}-"
                          "${entry.date.month.toString().padLeft(2, '0')}-"
                          "${entry.date.year}",
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            if (weightDiff != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  bottom: 4,
                                ),
                                child: Text(
                                  "${weightDiff > 0 ? "+" : ""}"
                                  "$weightDiff ${l10n.unitGr}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: weightDiff > 0
                                        ? Colors.green
                                        : weightDiff < 0
                                        ? Colors.red
                                        : secondaryTextColor,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _infoRow(
                          context,
                          l10n.height,
                          "${entry.height} ${l10n.unitCm}",
                          heightDiff,
                        ),
                        if (entry.headCircumference != null)
                          _simpleRow(
                            context,
                            l10n.headCircumference,
                            "${entry.headCircumference} ${l10n.unitCm}",
                          ),
                        if (entry.waistCircumference != null)
                          _simpleRow(
                            context,
                            l10n.waistCircumference,
                            "${entry.waistCircumference} ${l10n.unitCm}",
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

  Widget _infoRow(BuildContext context, String label, String value, num? diff) {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170) ??
        Colors.grey;

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
                    : secondaryTextColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _simpleRow(BuildContext context, String label, String value) {
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170) ??
        Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 13,
          color: secondaryTextColor,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170) ??
        Colors.grey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          l10n.noGrowthDataYet,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: secondaryTextColor,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
