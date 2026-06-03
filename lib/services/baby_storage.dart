import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baby_profile.dart';

class BabyStorage {
  static const String key = "baby_profile";

  Future<void> saveProfile(BabyProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(profile.toJson()));
  }

  Future<BabyProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return null;
    return BabyProfile.fromJson(jsonDecode(data));
  }
}
