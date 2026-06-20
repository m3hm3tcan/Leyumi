import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SessionExpanded extends StatelessWidget {
  final FeedingSession session;
  final Duration leftTotal;
  final Duration rightTotal;

  const SessionExpanded({
    super.key,
    required this.session,
    required this.leftTotal,
    required this.rightTotal,
  });

  @override
  Widget build(BuildContext context) {
    final startW = session.startWeightGr;
    final endW = session.endWeightGr;
    final diff = session.milkIntakeGr;
    final l10n = AppLocalizations.of(context);
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170) ??
            Colors.grey;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${l10n.leftBreast}: ${leftTotal.inMinutes}m",
            style: TextStyle(
              color: Colors.pink.shade400,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "${l10n.rightBreast}: ${rightTotal.inMinutes}m",
            style: TextStyle(
              color: Colors.blue.shade400,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 14),
          if (startW != null && endW != null) ...[
            const Divider(),
            Text(
              "${l10n.initialWeight}: $startW ${l10n.unitGr}",
              style: TextStyle(color: secondaryTextColor),
            ),
            Text(
              "${l10n.finalWeight}: $endW ${l10n.unitGr}",
              style: TextStyle(color: secondaryTextColor),
            ),
            const SizedBox(height: 8),
          ],
          if ((diff ?? 0) > 0)
            Text(
              "${l10n.milkIntake}: $diff ${l10n.unitGr}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}
