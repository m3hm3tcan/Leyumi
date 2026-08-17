import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/milk_inventory/milk_batch.dart';
import 'package:leyumi/models/baby_profile.dart';
import 'package:leyumi/services/baby_storage.dart';
import 'package:leyumi/services/diaper_storage.dart';
import 'package:leyumi/services/milk_inventory_storage.dart';

import 'sqlite_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(SqliteTestSupport.setUp);
  tearDown(SqliteTestSupport.tearDown);

  test(
    'keeps child records isolated and replaces only active child data',
    () async {
      final now = DateTime.utc(2026, 8, 13);
      final childOne = _profile('child-1', 'Ada', now);
      final childTwo = _profile('child-2', 'Mira', now);
      final babies = BabyStorage();
      final diapers = DiaperStorage();

      await babies.saveProfile(childOne);
      await babies.saveProfile(childTwo);
      await babies.setActiveProfile(childOne.id);
      await diapers.addEntry(_diaper('d1', childOne.id, now));
      await diapers.addEntry(_diaper('d2', childTwo.id, now));

      expect((await diapers.loadEntries()).map((e) => e.id), ['d1']);
      await diapers.saveAllEntries([]);
      expect(await diapers.loadEntries(), isEmpty);

      await babies.setActiveProfile(childTwo.id);
      expect((await diapers.loadEntries()).map((e) => e.id), ['d2']);
    },
  );

  test(
    'deletes a child and all linked records in one database operation',
    () async {
      final now = DateTime.utc(2026, 8, 13);
      final babies = BabyStorage();
      final diapers = DiaperStorage();
      await babies.saveProfile(_profile('child-1', 'Ada', now));
      await babies.saveProfile(_profile('child-2', 'Mira', now));
      await babies.setActiveProfile('child-1');
      await diapers.addEntry(_diaper('d1', 'child-1', now));
      await diapers.addEntry(_diaper('d2', 'child-2', now));

      await babies.deleteProfile('child-1');

      expect((await babies.loadProfiles()).map((e) => e.id), ['child-2']);
      expect(await babies.loadActiveProfileId(), 'child-2');
      expect((await diapers.loadEntries()).map((e) => e.id), ['d2']);
    },
  );

  test('updates a milk batch and appends its event atomically', () async {
    final now = DateTime.utc(2026, 8, 13);
    final babies = BabyStorage();
    await babies.saveProfile(_profile('child-1', 'Ada', now));
    final storage = MilkInventoryStorage();
    final batch = MilkBatch(
      id: 'batch-1',
      childId: 'child-1',
      labelNumber: '1',
      initialAmountMl: 120,
      remainingAmountMl: 120,
      expressedAt: now,
      storageLocation: MilkStorageLocation.refrigerator,
      sourceSide: MilkSourceSide.mixed,
      createdAt: now,
    );

    await storage.addBatch(batch);
    await storage.useMilk(batch: batch, amountMl: 40, usedAt: now);

    expect((await storage.loadBatches()).single.remainingAmountMl, 80);
    final events = await storage.loadEvents();
    expect(events.length, 2);
    expect(events.last.remainingAfterMl, 80);
  });
}

BabyProfile _profile(String id, String name, DateTime timestamp) => BabyProfile(
  id: id,
  name: name,
  gender: 'Female',
  birthDate: DateTime.utc(2026, 1, 1),
  weight: 6000,
  height: 60,
  createdAt: timestamp,
  updatedAt: timestamp,
);

DiaperEntry _diaper(String id, String childId, DateTime timestamp) =>
    DiaperEntry(
      id: id,
      childId: childId,
      timestamp: timestamp,
      type: DiaperType.pee,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
