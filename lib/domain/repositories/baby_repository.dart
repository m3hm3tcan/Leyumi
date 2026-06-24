import '../../models/baby_profile.dart';

abstract interface class BabyRepository {
  Future<void> saveProfile(BabyProfile profile);
  Future<BabyProfile?> loadProfile();
  Future<List<BabyProfile>> loadProfiles();
  Future<void> setActiveProfile(String profileId);
  Future<String?> loadActiveProfileId();
  Future<void> deleteProfile(String profileId);
}
