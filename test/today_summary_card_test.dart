import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/features/home/home_dashboard_service.dart';
import 'package:leyumi/features/home/home_dashboard_snapshot.dart';
import 'package:leyumi/features/home/widgets/today_summary_card.dart';
import 'package:leyumi/l10n/app_localizations.dart';

void main() {
  testWidgets('shows today totals and useful latest-record details', (
    tester,
  ) async {
    final now = DateTime.now();
    final snapshot = HomeDashboardSnapshot(
      todayFeedingCount: 2,
      todayFeedingDuration: const Duration(minutes: 30),
      todayDiaperCount: 1,
      todayPeeDiaperCount: 1,
      todayPoopDiaperCount: 0,
      lastFeeding: FeedingSession(
        childId: 'child-1',
        startTime: now.subtract(const Duration(minutes: 20)),
        endTime: now.subtract(const Duration(minutes: 8)),
        entries: [
          FeedingEntry(
            side: FeedingSide.left,
            duration: const Duration(minutes: 12),
          ),
        ],
      ),
      lastDiaper: DiaperEntry(
        childId: 'child-1',
        timestamp: now.subtract(const Duration(minutes: 8)),
        type: DiaperType.pee,
        peeAmount: PeeAmount.medium,
      ),
    );

    await tester.pumpWidget(_app(_FakeLoader(snapshot)));
    await tester.pumpAndSettle();

    expect(find.text('Bugünün özeti'), findsOneWidget);
    expect(find.text('2 beslenme · 1 bez'), findsOneWidget);
    expect(find.text('Bugünkü beslenme süresi: 30 dk'), findsOneWidget);
    expect(find.text('Sol · 12 dk'), findsOneWidget);
    expect(find.text('Son bez değişimi'), findsOneWidget);
  });

  testWidgets('shows an inline error and recovers on retry', (tester) async {
    final loader = _RetryLoader();
    await tester.pumpWidget(_app(loader));
    await tester.pumpAndSettle();

    expect(find.text('Ana ekran özeti yüklenemedi.'), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Bugünün özeti'), findsOneWidget);
    expect(find.text('Henüz beslenme kaydı yok'), findsOneWidget);
    expect(find.text('Henüz bez kaydı yok'), findsOneWidget);
  });
}

Widget _app(HomeDashboardLoader loader) => MaterialApp(
  locale: const Locale('tr'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: TodaySummaryCard(
        childId: 'child-1',
        refreshVersion: 0,
        loader: loader,
      ),
    ),
  ),
);

class _FakeLoader implements HomeDashboardLoader {
  _FakeLoader(this.snapshot);

  final HomeDashboardSnapshot snapshot;

  @override
  Future<HomeDashboardSnapshot> load({
    required String childId,
    DateTime? now,
  }) async => snapshot;
}

class _RetryLoader implements HomeDashboardLoader {
  int attempts = 0;

  @override
  Future<HomeDashboardSnapshot> load({
    required String childId,
    DateTime? now,
  }) async {
    if (attempts++ == 0) throw StateError('temporary failure');
    return const HomeDashboardSnapshot(
      todayFeedingCount: 0,
      todayFeedingDuration: Duration.zero,
      todayDiaperCount: 0,
      todayPeeDiaperCount: 0,
      todayPoopDiaperCount: 0,
    );
  }
}
