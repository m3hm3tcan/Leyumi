import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

enum FeedingSaveDecision { save, discard }

Future<FeedingSaveDecision?> showFeedingSaveDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<FeedingSaveDecision>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.save_outlined, color: Colors.green, size: 32),
      title: Text(l10n.confirmSaveTitle),
      content: Text(l10n.confirmSaveContent),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(dialogContext, FeedingSaveDecision.discard),
          child: Text(l10n.dontSave),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(dialogContext, FeedingSaveDecision.save),
          style: FilledButton.styleFrom(backgroundColor: Colors.green.shade600),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}
