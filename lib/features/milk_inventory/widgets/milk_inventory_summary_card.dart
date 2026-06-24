import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../milk_batch.dart';

class MilkInventorySummaryCard extends StatelessWidget {
  const MilkInventorySummaryCard({
    super.key,
    required this.totalMl,
    required this.activeBottleCount,
    required this.refrigeratorMl,
    required this.freezerMl,
    required this.leftMl,
    required this.rightMl,
    required this.mixedMl,
    required this.showSourceStats,
  });

  final int totalMl;
  final int activeBottleCount;
  final int refrigeratorMl;
  final int freezerMl;
  final int leftMl;
  final int rightMl;
  final int mixedMl;
  final bool showSourceStats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff6257D9), Color(0xff9A67DC)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff6257D9).withAlpha(55),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalMilkStock.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$totalMl ml',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.kitchen_rounded,
                  label: l10n.refrigerator,
                  value: '$refrigeratorMl ml',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.ac_unit_rounded,
                  label: l10n.freezer,
                  value: '$freezerMl ml',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.inventory_2_rounded,
                  label: l10n.bottles,
                  value: '$activeBottleCount',
                ),
              ),
            ],
          ),
          if (showSourceStats) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withAlpha(35)),
            const SizedBox(height: 13),
            Text(
              l10n.pumpedFrom,
              style: TextStyle(
                color: Colors.white.withAlpha(175),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _SourceMetric(l10n.leftLabel, leftMl)),
                const SizedBox(width: 8),
                Expanded(child: _SourceMetric(l10n.rightLabel, rightMl)),
                const SizedBox(width: 8),
                Expanded(child: _SourceMetric(l10n.mixed, mixedMl)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withAlpha(175), fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _SourceMetric extends StatelessWidget {
  const _SourceMetric(this.label, this.amount);

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label • $amount ml',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
