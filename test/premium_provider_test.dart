import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/core/premium/premium_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'premium remains disabled unless the explicit debug flag is used',
    () async {
      SharedPreferences.setMockInitialValues({
        PremiumProvider.entitlementKey: true,
      });
      final provider = PremiumProvider();

      await provider.ensureLoaded();

      expect(provider.isLoaded, isTrue);
      expect(provider.isPremium, isFalse);
    },
  );
}
