import 'package:flutter/foundation.dart';

import '../../diaper/diaper_entry.dart';
import 'home_preferences.dart';
import 'home_preferences_storage.dart';

class HomePreferencesProvider extends ChangeNotifier {
  HomePreferencesProvider({HomePreferencesStore? storage})
    : _storage = storage ?? const HomePreferencesStorage() {
    _initialization = _load();
  }

  final HomePreferencesStore _storage;
  late final Future<void> _initialization;
  HomePreferences _value = HomePreferences.defaults();
  bool _isLoaded = false;
  Object? _loadError;

  HomePreferences get value => _value;
  bool get isLoaded => _isLoaded;
  Object? get loadError => _loadError;
  Future<void> ensureLoaded() => _initialization;

  Future<void> _load() async {
    try {
      _value = await _storage.load();
      _loadError = null;
    } catch (error) {
      _loadError = error;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setDashboardVisible(HomeDashboardCard card, bool visible) =>
      _update(
        _value.copyWith(
          visibleDashboardCards: _updatedVisibility(
            _value.visibleDashboardCards,
            card,
            visible,
          ),
        ),
      );

  Future<void> setQuickActionVisible(HomeQuickAction action, bool visible) =>
      _update(
        _value.copyWith(
          visibleQuickActions: _updatedVisibility(
            _value.visibleQuickActions,
            action,
            visible,
          ),
        ),
      );

  Future<void> moveDashboard(HomeDashboardCard card, int offset) => _update(
    _value.copyWith(
      dashboardOrder: _moved(_value.dashboardOrder, card, offset),
    ),
  );

  Future<void> moveQuickAction(HomeQuickAction action, int offset) => _update(
    _value.copyWith(
      quickActionOrder: _moved(_value.quickActionOrder, action, offset),
    ),
  );

  Future<void> setPreferredQuickDiaperType(DiaperType type) =>
      _update(_value.copyWith(preferredQuickDiaperType: type));

  Future<void> resetToDefaults() => _update(HomePreferences.defaults());

  void resetAfterAppDataCleared() {
    _value = HomePreferences.defaults();
    _loadError = null;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _update(HomePreferences next) async {
    final previous = _value;
    _value = next;
    notifyListeners();
    try {
      await _storage.save(next);
    } catch (_) {
      _value = previous;
      notifyListeners();
      rethrow;
    }
  }

  Set<T> _updatedVisibility<T>(Set<T> source, T item, bool visible) {
    final result = Set<T>.of(source);
    visible ? result.add(item) : result.remove(item);
    return result;
  }

  List<T> _moved<T>(List<T> source, T item, int offset) {
    final result = List<T>.of(source);
    final oldIndex = result.indexOf(item);
    if (oldIndex < 0) return result;
    final newIndex = (oldIndex + offset).clamp(0, result.length - 1);
    if (newIndex == oldIndex) return result;
    result
      ..removeAt(oldIndex)
      ..insert(newIndex, item);
    return result;
  }
}
