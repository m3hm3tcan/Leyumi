import 'package:leyumi/features/history/graphs/diaper_graph.dart';
import 'package:leyumi/features/history/graphs/feeding_graph.dart';
import 'package:leyumi/features/history/graphs/growth_graph.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'tabs/diaper_tab.dart';
import 'tabs/feeding_tab.dart';
import 'tabs/growth_tab.dart';
import 'widgets/hub_card.dart';

class HistoryHubScreen extends StatelessWidget {
  const HistoryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                l10n.historyHubTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.historyHubSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  children: [
                    HubCard(
                      title: l10n.feeding,
                      icon: Icons.local_drink_rounded,
                      color: const Color(0xff4DA3FF),
                      subtitle: l10n.milkTracking,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedingTab(),
                          ),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.feedingGraph,
                      icon: Icons.show_chart,
                      color: const Color(0xff3B82F6),
                      subtitle: l10n.viewCharts,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedingGraphScreen(),
                          ),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.diaper,
                      icon: Icons.baby_changing_station,
                      color: const Color(0xffF59E0B),
                      subtitle: l10n.diaperChanges,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DiaperTab(),
                          ),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.diaperGraph,
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xffD97706),
                      subtitle: l10n.viewCharts,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DiaperGraphScreen(),
                          ),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.growth,
                      icon: Icons.show_chart_rounded,
                      color: const Color(0xff22C55E),
                      subtitle: l10n.weightAndHeight,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GrowthTab(),
                          ),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.growthGraph,
                      icon: Icons.area_chart_rounded,
                      color: const Color(0xff16A34A),
                      subtitle: l10n.viewCharts,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GrowthGraphScreen(),
                          ),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.sleepTitle,
                      icon: Icons.nightlight_round,
                      color: const Color(0xff8B5CF6),
                      subtitle: l10n.comingSoon,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
