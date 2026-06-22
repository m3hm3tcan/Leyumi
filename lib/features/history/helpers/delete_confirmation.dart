import 'package:flutter/material.dart';
import 'package:leyumi/l10n/app_localizations.dart';

Future<bool> confirmHistoryDelete(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 32,
        ),
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteContent),
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
      );
    },
  );

  return confirmed ?? false;
}
