import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leyumi/core/premium/premium_provider.dart';
import 'package:leyumi/features/feeding/bottle_portion.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/features/feeding/sheets/bottle_meal_sheet.dart';
import 'package:leyumi/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<PremiumProvider> showSheet(
    WidgetTester tester, {
    required bool premium,
    BottleMilk milk = BottleMilk.expressed,
    String language = 'en',
  }) async {
    final provider = PremiumProvider();
    await provider.ensureLoaded();
    await provider.updateEntitlement(isPremium: premium);
    final now = DateTime.now().subtract(const Duration(minutes: 1));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: BottleMealSheet(
              initialMilk: milk,
              meal: FeedingSession(
                childId: 'baby',
                startTime: now,
                endTime: now,
                entries: [],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  testWidgets('free expressed milk entry has no inventory control or upsell', (
    tester,
  ) async {
    await showSheet(tester, premium: false);
    expect(find.text('Use from inventory'), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.text('Amount consumed'), findsOneWidget);
    await tester.tap(find.text('90 ml'));
    expect(find.widgetWithText(TextFormField, '90'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'only premium expressed milk displays inventory, reacts to entitlement',
    (tester) async {
      final provider = await showSheet(tester, premium: true);
      expect(find.text('Use from inventory'), findsOneWidget);
      await provider.updateEntitlement(isPremium: false);
      await tester.pumpAndSettle();
      expect(find.text('Use from inventory'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('formula never displays inventory even with premium', (
    tester,
  ) async {
    await showSheet(tester, premium: true, milk: BottleMilk.formula);
    expect(find.text('Use from inventory'), findsNothing);
    expect(find.text('Formula'), findsWidgets);
  });

  testWidgets('invalid zero amount is rejected before saving', (tester) async {
    await showSheet(tester, premium: false);
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.ensureVisible(find.text('Save meal'));
    await tester.tap(find.text('Save meal'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a whole number greater than zero.'),
      findsOneWidget,
    );
  });

  for (final language in ['tr', 'hu']) {
    testWidgets('$language form fits a narrow phone', (tester) async {
      tester.view.reset();
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await showSheet(tester, premium: true, language: language);
      expect(tester.takeException(), isNull);
    });
  }
}
