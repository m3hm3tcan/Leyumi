import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'tabs/diaper_tab.dart';
import 'tabs/feeding_tab.dart';
import 'tabs/growth_tab.dart';
import 'widgets/category_center_shell.dart';

class RecordsCenterScreen extends StatefulWidget {
  const RecordsCenterScreen({super.key});

  @override
  State<RecordsCenterScreen> createState() => _RecordsCenterScreenState();
}

class _RecordsCenterScreenState extends State<RecordsCenterScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CategoryCenterShell(
      title: l10n.history,
      selectedIndex: _selectedIndex,
      onSelected: (index) => setState(() => _selectedIndex = index),
      options: [
        CategoryCenterOption(
          label: l10n.feeding,
          icon: Icons.local_drink_rounded,
          color: const Color(0xff4DA3FF),
        ),
        CategoryCenterOption(
          label: l10n.diaper,
          icon: Icons.baby_changing_station_rounded,
          color: const Color(0xffF59E0B),
        ),
        CategoryCenterOption(
          label: l10n.growth,
          icon: Icons.monitor_weight_rounded,
          color: const Color(0xff22C55E),
        ),
      ],
      children: const [
        FeedingTab(embedded: true),
        DiaperTab(embedded: true),
        GrowthTab(embedded: true),
      ],
    );
  }
}
