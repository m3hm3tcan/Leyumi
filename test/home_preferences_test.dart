import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/home/preferences/home_preferences.dart';
import 'package:leyumi/features/home/preferences/home_preferences_provider.dart';
import 'package:leyumi/features/home/preferences/home_preferences_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restores a partial older layout and appends newly known cards', () {
    final preferences = HomePreferences.fromJson({
      'dashboardOrder': ['quickDiaper', 'unknown'],
      'visibleDashboardCards': ['quickDiaper'],
      'quickActionOrder': ['history', 'feeding'],
      'visibleQuickActions': ['history'],
      'preferredQuickDiaperType': 'poop',
    });

    expect(preferences.dashboardOrder, [
      HomeDashboardCard.quickDiaper,
      HomeDashboardCard.todaySummary,
      HomeDashboardCard.upcomingCare,
    ]);
    expect(preferences.visibleDashboardCards, {HomeDashboardCard.quickDiaper});
    expect(preferences.quickActionOrder.first, HomeQuickAction.history);
    expect(
      preferences.quickActionOrder,
      hasLength(HomeQuickAction.values.length),
    );
    expect(preferences.visibleQuickActions, {HomeQuickAction.history});
    expect(preferences.preferredQuickDiaperType, DiaperType.poop);
  });

  test('persists home preferences without child records', () async {
    SharedPreferences.setMockInitialValues({});
    const storage = HomePreferencesStorage();
    final changed = HomePreferences.defaults().copyWith(
      dashboardOrder: [
        HomeDashboardCard.upcomingCare,
        HomeDashboardCard.todaySummary,
        HomeDashboardCard.quickDiaper,
      ],
      visibleQuickActions: {HomeQuickAction.feeding},
      preferredQuickDiaperType: DiaperType.both,
    );

    await storage.save(changed);
    final restored = await storage.load();

    expect(restored.dashboardOrder, changed.dashboardOrder);
    expect(restored.visibleQuickActions, {HomeQuickAction.feeding});
    expect(restored.preferredQuickDiaperType, DiaperType.both);
    final raw = (await SharedPreferences.getInstance()).getString(
      HomePreferencesStorage.storageKey,
    );
    expect(raw, isNot(contains('child')));
  });

  test('provider moves, hides and resets cards', () async {
    final storage = _MemoryStore();
    final provider = HomePreferencesProvider(storage: storage);
    await provider.ensureLoaded();

    await provider.moveDashboard(HomeDashboardCard.quickDiaper, -1);
    await provider.setQuickActionVisible(HomeQuickAction.milkInventory, false);
    await provider.setPreferredQuickDiaperType(DiaperType.poop);

    expect(provider.value.dashboardOrder.first, HomeDashboardCard.quickDiaper);
    expect(
      provider.value.visibleQuickActions,
      isNot(contains(HomeQuickAction.milkInventory)),
    );
    expect(provider.value.preferredQuickDiaperType, DiaperType.poop);
    expect(storage.value?.preferredQuickDiaperType, DiaperType.poop);

    await provider.resetToDefaults();

    expect(provider.value.dashboardOrder, HomeDashboardCard.values);
    expect(provider.value.visibleQuickActions, HomeQuickAction.values.toSet());
    expect(provider.value.preferredQuickDiaperType, DiaperType.pee);
  });
}

class _MemoryStore implements HomePreferencesStore {
  HomePreferences? value;

  @override
  Future<HomePreferences> load() async => value ?? HomePreferences.defaults();

  @override
  Future<void> save(HomePreferences preferences) async => value = preferences;
}
