import 'package:leyumi/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract final class SqliteTestSupport {
  static Future<void> setUp({
    Map<String, Object> preferences = const {},
  }) async {
    sqfliteFfiInit();
    await AppDatabase.configureForTesting(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    SharedPreferences.setMockInitialValues(preferences);
  }

  static Future<void> tearDown() async {
    await AppDatabase.close();
  }
}
