import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../core/premium/premium_access.dart';
import '../../core/premium/premium_feature.dart';
import '../../features/care_report/care_report_screen.dart';
import '../../features/milk_inventory/milk_history_screen.dart';
import '../../l10n/app_localizations.dart';
import 'analytics_center_screen.dart';
import 'records_center_screen.dart';
import 'widgets/hub_card.dart';

class HistoryHubScreen extends StatelessWidget {
  const HistoryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;
    final childName = context.watch<ActiveChildProvider>().activeChild?.name;

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
                childName == null
                    ? l10n.historyHubSubtitle
                    : '${l10n.historyHubSubtitle} · $childName',
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
                      title: l10n.history,
                      icon: Icons.view_timeline_rounded,
                      color: const Color(0xff4DA3FF),
                      subtitle: l10n.recordsOverview,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecordsCenterScreen(),
                          ),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.analytics,
                      icon: Icons.insights_rounded,
                      color: const Color(0xff22A987),
                      subtitle: l10n.premiumAnalytics,
                      isPremium: true,
                      onTap: () {
                        PremiumAccess.open(
                          context,
                          feature: PremiumFeature.advancedAnalytics,
                          builder: (_) => const AnalyticsCenterScreen(),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.milkHistory,
                      icon: Icons.history,
                      color: const Color(0xff7C5CE7),
                      subtitle: l10n.usedAndRemainingMilk,
                      isPremium: true,
                      onTap: () {
                        PremiumAccess.open(
                          context,
                          feature: PremiumFeature.milkInventory,
                          builder: (_) => const MilkHistoryScreen(),
                        );
                      },
                    ),
                    HubCard(
                      title: l10n.careReport,
                      icon: Icons.picture_as_pdf,
                      color: const Color(0xffE05273),
                      subtitle: l10n.createShareableReport,
                      isPremium: true,
                      onTap: () {
                        PremiumAccess.open(
                          context,
                          feature: PremiumFeature.pdfReports,
                          builder: (_) => const CareReportScreen(),
                        );
                      },
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
