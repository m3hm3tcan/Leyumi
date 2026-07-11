import 'package:shared_preferences/shared_preferences.dart';

class ResetService {
  static Future<void> clearAll() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}
