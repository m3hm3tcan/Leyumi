import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'premium_feature.dart';

class PremiumProvider extends ChangeNotifier {
  static const entitlementKey = 'premium_entitlement_active';

  PremiumProvider() {
    _initialization = _loadEntitlement();
  }

  late final Future<void> _initialization;
  bool _isPremium = false;
  bool _isLoaded = false;

  bool get isPremium => _isPremium;
  bool get isLoaded => _isLoaded;
  Future<void> ensureLoaded() => _initialization;

  bool hasAccess(PremiumFeature feature) => _isPremium;

  Future<void> _loadEntitlement() async {
    final preferences = await SharedPreferences.getInstance();
    // _isPremium = kDebugMode
    //     ? true
    //     : preferences.getBool(entitlementKey) ?? false;
    _isPremium = true;
    _isLoaded = true;
    notifyListeners();
  }

  /// Call this method after App Store / Google Play purchase validation.
  Future<void> updateEntitlement({required bool isPremium}) async {
    _isPremium = isPremium;
    _isLoaded = true;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(entitlementKey, isPremium);
    notifyListeners();
  }
}
