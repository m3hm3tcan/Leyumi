import 'package:flutter/foundation.dart';

import '../../models/baby_profile.dart';
import '../../services/baby_storage.dart';

class ActiveChildProvider extends ChangeNotifier {
  ActiveChildProvider({BabyStorage? storage})
    : _storage = storage ?? BabyStorage() {
    _initialization = _initialize().catchError((_) {});
  }

  final BabyStorage _storage;
  late final Future<void> _initialization;
  List<BabyProfile> _profiles = [];
  BabyProfile? _activeChild;
  bool _isLoaded = false;
  Object? _loadError;

  List<BabyProfile> get profiles => List.unmodifiable(_profiles);
  BabyProfile? get activeChild => _activeChild;
  String? get activeChildId => _activeChild?.id;
  bool get isLoaded => _isLoaded;
  Object? get loadError => _loadError;
  bool get hasProfiles => _profiles.isNotEmpty;
  Future<void> ensureLoaded() => _initialization;

  Future<void> _initialize() => reload();

  Future<void> reload() async {
    try {
      _profiles = await _storage.loadProfiles();
      _activeChild = await _storage.loadProfile();
      _loadError = null;
    } catch (error) {
      _loadError = error;
      rethrow;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> selectChild(String profileId) async {
    await _storage.setActiveProfile(profileId);
    _activeChild = _profiles.firstWhere((profile) => profile.id == profileId);
    notifyListeners();
  }

  Future<void> saveChild(BabyProfile profile) async {
    final isNew = !_profiles.any((item) => item.id == profile.id);
    await _storage.saveProfile(profile);
    if (isNew) await _storage.setActiveProfile(profile.id);
    await reload();
  }

  Future<void> deleteChild(String profileId) async {
    if (_profiles.length <= 1) return;
    await _storage.deleteProfile(profileId);
    await reload();
  }
}
