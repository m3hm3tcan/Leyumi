import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/domain/repositories/diaper_repository.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/home/quick_diaper_service.dart';
import 'package:leyumi/features/home/widgets/quick_diaper_card.dart';
import 'package:leyumi/l10n/app_localizations.dart';

void main() {
  testWidgets('saves a quick diaper and offers undo', (tester) async {
    final repository = _FakeRepository();
    final service = QuickDiaperService(repository: repository);
    var changes = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: QuickDiaperCard(
            childId: 'child-1',
            service: service,
            onChanged: () => changes++,
            onOpenDetails: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Islak'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(repository.entries, hasLength(1));
    expect(repository.entries.single.type, DiaperType.pee);
    expect(find.text('Islak bez kaydedildi.'), findsOneWidget);
    expect(changes, 1);

    await tester.tap(find.text('GERİ AL'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(repository.entries, isEmpty);
    expect(changes, 2);
  });
}

class _FakeRepository implements DiaperRepository {
  final entries = <DiaperEntry>[];

  @override
  Future<void> addEntry(DiaperEntry entry) async => entries.add(entry);

  @override
  Future<void> deleteEntry({
    required String id,
    required String childId,
  }) async => entries.removeWhere((entry) => entry.id == id);

  @override
  Future<List<DiaperEntry>> loadEntries() async => List.of(entries);

  @override
  Future<void> saveAllEntries(List<DiaperEntry> entries) async {}
}
