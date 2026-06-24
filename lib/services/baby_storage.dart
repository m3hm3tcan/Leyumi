import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baby_profile.dart';
import '../domain/repositories/baby_repository.dart';
import '../core/logging/app_logger.dart';

class BabyStorage implements BabyRepository {
  static const String key = "baby_profile";

  Future<void> saveProfile(BabyProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(profile.toJson()));
  }

  Future<BabyProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return null;
    try {
      return BabyProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(data) as Map),
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'The baby profile could not be read.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
