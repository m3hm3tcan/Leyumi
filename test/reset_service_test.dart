import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/services/reset_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reset removes every locally stored value', () async {
    SharedPreferences.setMockInitialValues({
      'baby_profiles_v2': '[{"id":"child-1"}]',
      'feeding_sessions': <String>['{"id":"feeding-1"}'],
      'premium_entitlement_active': true,
      'darkMode': true,
    });

    await ResetService.clearAll();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), isEmpty);
  });
}
