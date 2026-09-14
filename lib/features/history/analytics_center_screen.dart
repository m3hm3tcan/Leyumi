import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'graphs/diaper_graph.dart';
import 'graphs/feeding_graph.dart';
import 'graphs/growth_graph.dart';
import 'widgets/category_center_shell.dart';

class AnalyticsCenterScreen extends StatefulWidget {
  const AnalyticsCenterScreen({super.key});

  @override
  State<AnalyticsCenterScreen> createState() => _AnalyticsCenterScreenState();
}

class _AnalyticsCenterScreenState extends State<AnalyticsCenterScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CategoryCenterShell(
      title: l10n.analytics,
      selectedIndex: _selectedIndex,
      onSelected: (index) => setState(() => _selectedIndex = index),
      options: [
        CategoryCenterOption(
          label: l10n.feeding,
          icon: Icons.local_drink_rounded,
          color: const Color(0xff4F7DFF),
        ),
        CategoryCenterOption(
          label: l10n.diaper,
          icon: Icons.baby_changing_station_rounded,
          color: const Color(0xffF59E0B),
        ),
        CategoryCenterOption(
          label: l10n.growth,
          icon: Icons.auto_graph_rounded,
          color: const Color(0xff21B981),
        ),
      ],
      children: const [
        FeedingGraphScreen(embedded: true),
        DiaperGraphScreen(embedded: true),
        GrowthGraphScreen(embedded: true),
      ],
    );
  }
}
