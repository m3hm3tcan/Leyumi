import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/premium/premium_paywall_screen.dart';
import 'premium_feature.dart';
import 'premium_provider.dart';

class PremiumAccess {
  const PremiumAccess._();

  static bool hasAccess(BuildContext context, PremiumFeature feature) {
    return context.read<PremiumProvider>().hasAccess(feature);
  }

  static Future<void> open(
    BuildContext context, {
    required PremiumFeature feature,
    required WidgetBuilder builder,
  }) async {
    final premium = context.read<PremiumProvider>();
    await premium.ensureLoaded();
    if (!context.mounted) return;

    final destination = premium.hasAccess(feature)
        ? builder(context)
        : PremiumPaywallScreen(feature: feature);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }
}
