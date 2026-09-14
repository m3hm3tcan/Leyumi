import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/baby_profile.dart';
import 'widgets/child_profile_form.dart';

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key, this.profile});

  final BabyProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          profile == null ? l10n.addChildProfile : l10n.editChildProfile,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ChildProfileForm(
          initialProfile: profile,
          submitLabel: l10n.save,
          onSaved: (child) async {
            await context.read<ActiveChildProvider>().saveChild(child);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
