import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_empty_state.dart';

class MilkInventoryEmptyState extends StatelessWidget {
  const MilkInventoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: Icons.local_drink_rounded,
      title: l10n.noStoredMilk,
      description: l10n.noStoredMilkHint,
    );
  }
}
