import 'package:flutter/foundation.dart';

import '../../models/baby_profile.dart';
import '../../services/baby_storage.dart';
import '../../services/child_data_migration_service.dart';

class ActiveChildProvider extends ChangeNotifier {
  ActiveChildProvider({BabyStorage? storage})
    : _storage = storage ?? BabyStorage() {
    _initialization = _initialize();
  }

  final BabyStorage _storage;
  late final Future<void> _initialization;
  List<BabyProfile> _profiles = [];
  BabyProfile? _activeChild;
  bool _isLoaded = false;

  List<BabyProfile> get profiles => List.unmodifiable(_profiles);
  BabyProfile? get activeChild => _activeChild;
  String? get activeChildId => _activeChild?.id;
  bool get isLoaded => _isLoaded;
  bool get hasProfiles => _profiles.isNotEmpty;
  Future<void> ensureLoaded() => _initialization;

  Future<void> _initialize() async {
    await _storage.loadProfiles();
    await ChildDataMigrationService().migrateIfNeeded();
    await reload();
  }

  Future<void> reload() async {
    _profiles = await _storage.loadProfiles();
    _activeChild = await _storage.loadProfile();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> selectChild(String profileId) async {
    await _storage.setActiveProfile(profileId);
    _activeChild = _profiles.firstWhere((profile) => profile.id == profileId);
    notifyListeners();
  }

  Future<void> saveChild(BabyProfile profile) async {
    await _storage.saveProfile(profile);
    await reload();
    await selectChild(profile.id);
  }

  Future<void> deleteChild(String profileId) async {
    await _storage.deleteProfile(profileId);
    await reload();
  }
}
