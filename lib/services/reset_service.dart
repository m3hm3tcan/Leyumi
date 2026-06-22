import 'package:leyumi/core/premium/premium_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetService {
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final premiumEntitlement =
        prefs.getBool(PremiumProvider.entitlementKey) ?? false;

    await prefs.clear();

    if (premiumEntitlement) {
      await prefs.setBool(PremiumProvider.entitlementKey, true);
    }
  }
}
