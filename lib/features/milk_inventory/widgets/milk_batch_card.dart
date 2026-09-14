import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../milk_batch.dart';
import 'milk_bottle_painter.dart';

class MilkBatchCard extends StatelessWidget {
  const MilkBatchCard({
    super.key,
    required this.batch,
    required this.onUse,
    required this.onDiscard,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  final MilkBatch batch;
  final VoidCallback onUse;
  final VoidCallback onDiscard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final freshness = _freshness(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: freshness.color.withAlpha(45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              theme.brightness == Brightness.dark ? 32 : 10,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: batch.fillRatio),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => SizedBox(
              width: 74,
              height: 128,
              child: CustomPaint(painter: MilkBottlePainter(fillRatio: value)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        batch.labelNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _menu(l10n),
                  ],
                ),
                Text(
                  '${batch.remainingAmountMl} / 500 ml',
                  style: const TextStyle(
                    color: Color(0xff6D63E8),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _chip(
                      batch.storageLocation == MilkStorageLocation.refrigerator
                          ? Icons.kitchen_rounded
                          : Icons.ac_unit_rounded,
                      batch.storageLocation == MilkStorageLocation.refrigerator
                          ? l10n.refrigerator
                          : l10n.freezer,
                    ),
                    _chip(Icons.favorite_outline_rounded, _sourceLabel(l10n)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.expressedAt}: ${_expressedLabel(context)}',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(155),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: freshness.color,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        freshness.label,
                        style: TextStyle(
                          color: freshness.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onUse,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff6D63E8),
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(l10n.useMilk),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(AppLocalizations l10n) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'move') onMove();
        if (value == 'edit') onEdit();
        if (value == 'discard') onDiscard();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        if (batch.storageLocation == MilkStorageLocation.refrigerator)
          PopupMenuItem(value: 'move', child: Text(l10n.moveToFreezer)),
        PopupMenuItem(value: 'edit', child: Text(l10n.editMilkRecord)),
        PopupMenuItem(value: 'discard', child: Text(l10n.discardMilk)),
        PopupMenuItem(value: 'delete', child: Text(l10n.deleteIncorrectRecord)),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xff6D63E8).withAlpha(15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xff6D63E8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _sourceLabel(AppLocalizations l10n) {
    return switch (batch.sourceSide) {
      MilkSourceSide.left => l10n.leftLabel,
      MilkSourceSide.right => l10n.rightLabel,
      MilkSourceSide.mixed => l10n.mixed,
      MilkSourceSide.unspecified => l10n.unspecified,
    };
  }

  String _expressedLabel(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatShortDate(batch.expressedAt)} • '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(batch.expressedAt))}';
  }

  ({String label, Color color}) _freshness(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remaining = batch.bestBefore.difference(DateTime.now());
    final bestBefore = _bestBeforeLabel(context);

    if (remaining.isNegative) {
      return (label: '${l10n.expired} • $bestBefore', color: Colors.redAccent);
    }
    if (remaining.inHours < 24) {
      return (
        label:
            '${l10n.useWithin} ${remaining.inHours + 1} '
            '${l10n.hoursShort} • $bestBefore',
        color: Colors.orange,
      );
    }
    if (remaining.inDays < 7) {
      return (
        label:
            '${l10n.freshFor} ${remaining.inDays + 1} '
            '${l10n.daysShort} • $bestBefore',
        color: remaining.inDays <= 1 ? Colors.orange : Colors.green,
      );
    }

    final months = (remaining.inDays / 30).ceil();
    return (
      label: '${l10n.freshFor} $months ${l10n.monthsShort} • $bestBefore',
      color: Colors.green,
    );
  }

  String _bestBeforeLabel(BuildContext context) {
    return '${AppLocalizations.of(context).bestBefore}: '
        '${MaterialLocalizations.of(context).formatShortDate(batch.bestBefore)}';
  }
}
