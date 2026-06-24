import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/logging/app_logger.dart';
import '../domain/repositories/baby_repository.dart';
import '../models/baby_profile.dart';

class BabyStorage implements BabyRepository {
  static const legacyKey = 'baby_profile';
  static const profilesKey = 'baby_profiles_v2';
  static const activeProfileKey = 'active_baby_profile_id';

  @override
  Future<void> saveProfile(BabyProfile profile) async {
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((item) => item.id == profile.id);
    if (index < 0) {
      profiles.add(profile);
    } else {
      profiles[index] = profile;
    }
    await _saveProfiles(profiles);

    final activeId = await loadActiveProfileId();
    if (activeId == null || profiles.length == 1) {
      await setActiveProfile(profile.id);
    }
  }

  @override
  Future<BabyProfile?> loadProfile() async {
    final profiles = await loadProfiles();
    if (profiles.isEmpty) return null;
    final activeId = await loadActiveProfileId();
    for (final profile in profiles) {
      if (profile.id == activeId) return profile;
    }
    return profiles.first;
  }

  @override
  Future<List<BabyProfile>> loadProfiles() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(profilesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded
            .map(
              (item) =>
                  BabyProfile.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      } catch (error, stackTrace) {
        AppLogger.warning(
          'Baby profiles could not be read.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    final legacy = await _loadLegacyProfile(preferences);
    if (legacy == null) return [];
    await _saveProfiles([legacy]);
    await setActiveProfile(legacy.id);
    return [legacy];
  }

  @override
  Future<void> setActiveProfile(String profileId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(activeProfileKey, profileId);
  }

  @override
  Future<String?> loadActiveProfileId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(activeProfileKey);
  }

  @override
  Future<void> deleteProfile(String profileId) async {
    final profiles = await loadProfiles();
    profiles.removeWhere((profile) => profile.id == profileId);
    await _saveProfiles(profiles);

    final activeId = await loadActiveProfileId();
    if (activeId == profileId) {
      final preferences = await SharedPreferences.getInstance();
      if (profiles.isEmpty) {
        await preferences.remove(activeProfileKey);
      } else {
        await setActiveProfile(profiles.first.id);
      }
    }
  }

  Future<void> _saveProfiles(List<BabyProfile> profiles) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      profilesKey,
      jsonEncode(profiles.map((profile) => profile.toJson()).toList()),
    );
  }

  Future<BabyProfile?> _loadLegacyProfile(SharedPreferences preferences) async {
    final raw = preferences.getString(legacyKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return BabyProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'The legacy baby profile could not be read.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
