import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../milk_batch.dart';

Future<bool> showDeleteMilkDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deleteMilkTitle),
          content: Text(l10n.deleteMilkContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text(l10n.delete),
            ),
          ],
        ),
      ) ??
      false;
}

Future<int?> showMilkAmountDialog(
  BuildContext context, {
  required MilkBatch batch,
  required String title,
  bool destructive = false,
}) {
  final l10n = AppLocalizations.of(context);
  var amount = batch.remainingAmountMl.toDouble();
  return showDialog<int>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${amount.round()} ml',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            if (batch.remainingAmountMl > 1)
              Slider(
                value: amount,
                min: 1,
                max: batch.remainingAmountMl.toDouble(),
                divisions: batch.remainingAmountMl - 1,
                onChanged: (value) => setDialogState(() => amount = value),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, amount.round()),
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: Colors.redAccent)
                : null,
            child: Text(l10n.confirm),
          ),
        ],
      ),
    ),
  );
}
