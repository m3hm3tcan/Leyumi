import 'package:shared_preferences/shared_preferences.dart';

class ResetService {
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
