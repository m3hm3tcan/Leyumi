import 'package:flutter/material.dart';
import 'package:leyumi/core/premium/premium_feature.dart';
import 'package:leyumi/l10n/app_localizations.dart';

class PremiumPaywallScreen extends StatelessWidget {
  const PremiumPaywallScreen({
    super.key,
    required this.feature,
  });

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.premiumTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff5B6CFF), Color(0xff9B5DE5)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff6C63FF).withAlpha(65),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.unlockPremium,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.premiumDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(210),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.premiumIncludes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _featureTile(
                context,
                icon: Icons.insights_rounded,
                title: l10n.premiumAnalytics,
                active: feature == PremiumFeature.advancedAnalytics,
                available: true,
              ),
              _featureTile(
                context,
                icon: Icons.picture_as_pdf_rounded,
                title: l10n.premiumPdfReports,
                active: feature == PremiumFeature.pdfReports,
                available: true,
              ),
              _featureTile(
                context,
                icon: Icons.child_care_rounded,
                title: l10n.premiumMultipleChildren,
                active: feature == PremiumFeature.multipleChildren,
                available: false,
              ),
              _featureTile(
                context,
                icon: Icons.cloud_done_rounded,
                title: l10n.premiumCloudBackup,
                active: feature == PremiumFeature.cloudBackup,
                available: false,
              ),
              _featureTile(
                context,
                icon: Icons.notifications_active_rounded,
                title: l10n.premiumSmartReminders,
                active: feature == PremiumFeature.smartReminders,
                available: false,
              ),
              _featureTile(
                context,
                icon: Icons.inventory_2_rounded,
                title: l10n.premiumMilkInventory,
                active: feature == PremiumFeature.milkInventory,
                available: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.premiumPurchaseComingSoon)),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: Text(l10n.upgradeToPremium),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff6558E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.premiumPurchaseComingSoon,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool active,
    required bool available,
  }) {
    final theme = Theme.of(context);
    const accent = Color(0xff6558E8);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: active ? accent.withAlpha(18) : theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? accent.withAlpha(100)
              : theme.dividerColor.withAlpha(65),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (available)
            Icon(
              active ? Icons.lock_rounded : Icons.check_circle_rounded,
              color: active ? accent : Colors.green,
              size: 19,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: theme.dividerColor.withAlpha(35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLocalizations.of(context).comingSoon,
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withAlpha(155),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
