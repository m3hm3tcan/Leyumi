import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_logger.dart';
import 'home_preferences.dart';

abstract interface class HomePreferencesStore {
  Future<HomePreferences> load();
  Future<void> save(HomePreferences preferences);
}

class HomePreferencesStorage implements HomePreferencesStore {
  const HomePreferencesStorage();

  static const storageKey = 'home_preferences_v1';

  @override
  Future<HomePreferences> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(storageKey);
    if (raw == null) return HomePreferences.defaults();
    try {
      return HomePreferences.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Home preferences could not be read; defaults will be used.',
        error: error,
        stackTrace: stackTrace,
      );
      return HomePreferences.defaults();
    }
  }

  @override
  Future<void> save(HomePreferences value) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(storageKey, jsonEncode(value));
    if (!saved) throw StateError('Home preferences could not be saved.');
  }
}
