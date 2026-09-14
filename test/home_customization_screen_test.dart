import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/home/preferences/home_preferences.dart';
import 'package:leyumi/features/home/preferences/home_preferences_provider.dart';
import 'package:leyumi/features/home/preferences/home_preferences_storage.dart';
import 'package:leyumi/features/settings/home_customization_screen.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('hides and moves a dashboard card with accessible controls', (
    tester,
  ) async {
    final provider = HomePreferencesProvider(storage: _MemoryStore());
    await provider.ensureLoaded();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeCustomizationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final quickDiaperRow = find.byKey(
      const ValueKey(HomeDashboardCard.quickDiaper),
    );
    expect(find.text('Ana ekranı düzenle'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: quickDiaperRow,
        matching: find.byTooltip('Yukarı taşı'),
      ),
    );
    await tester.pumpAndSettle();
    expect(provider.value.dashboardOrder.first, HomeDashboardCard.quickDiaper);

    final movedQuickDiaperRow = find.byKey(
      const ValueKey(HomeDashboardCard.quickDiaper),
    );
    await tester.tap(
      find.descendant(of: movedQuickDiaperRow, matching: find.byType(Switch)),
    );
    await tester.pumpAndSettle();

    expect(
      provider.value.visibleDashboardCards,
      isNot(contains(HomeDashboardCard.quickDiaper)),
    );
  });
}

class _MemoryStore implements HomePreferencesStore {
  HomePreferences value = HomePreferences.defaults();

  @override
  Future<HomePreferences> load() async => value;

  @override
  Future<void> save(HomePreferences preferences) async => value = preferences;
}
