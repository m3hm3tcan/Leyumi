import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/services/reset_service.dart';
import 'package:leyumi/models/baby_profile.dart';
import 'package:leyumi/services/baby_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sqlite_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(SqliteTestSupport.tearDown);

  test('reset removes SQLite records and every preference', () async {
    await SqliteTestSupport.setUp(
      preferences: {'premium_entitlement_active': true, 'darkMode': true},
    );
    await BabyStorage().saveProfile(
      BabyProfile(
        id: 'child-1',
        name: 'Ada',
        gender: 'Female',
        birthDate: DateTime.utc(2026, 1, 1),
        weight: 6000,
        height: 60,
      ),
    );

    await ResetService.clearAll();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), isEmpty);
    expect(await BabyStorage().loadProfiles(), isEmpty);
  });
}
