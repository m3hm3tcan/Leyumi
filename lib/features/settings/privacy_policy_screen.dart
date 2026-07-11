import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = <(String, String)>[
      (l10n.privacyDataTitle, l10n.privacyDataBody),
      (l10n.privacyStorageTitle, l10n.privacyStorageBody),
      (l10n.privacySharingTitle, l10n.privacySharingBody),
      (l10n.privacyRetentionTitle, l10n.privacyRetentionBody),
      (l10n.privacySecurityTitle, l10n.privacySecurityBody),
      (l10n.privacyContactTitle, l10n.privacyContactBody),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            l10n.privacyPolicyIntro,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 20),
          for (final section in sections) ...[
            Text(
              section.$1,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              section.$2,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            l10n.privacyPolicyEffectiveDate,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
