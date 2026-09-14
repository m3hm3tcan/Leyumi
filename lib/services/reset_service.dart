import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/app_database.dart';

class ResetService {
  static Future<void> clearAll() async {
    await AppDatabase.deleteAllData();
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}
