import '../../models/baby_profile.dart';

abstract interface class BabyRepository {
  Future<void> saveProfile(BabyProfile profile);
  Future<BabyProfile?> loadProfile();
}
