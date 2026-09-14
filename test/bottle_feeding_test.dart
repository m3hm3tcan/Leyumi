import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/feeding/bottle_portion.dart';
import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/features/milk_inventory/milk_batch.dart';
import 'package:leyumi/features/milk_inventory/milk_inventory_event.dart';
import 'package:leyumi/models/baby_profile.dart';
import 'package:leyumi/services/baby_storage.dart';
import 'package:leyumi/services/feeding_storage.dart';
import 'package:leyumi/services/milk_inventory_storage.dart';
import 'package:leyumi/services/backup_service.dart';
import 'package:leyumi/services/reset_service.dart';
import 'sqlite_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storage = FeedingStorage();
  final inventory = MilkInventoryStorage();
  late DateTime now;
  setUp(() async {
    await SqliteTestSupport.setUp();
    now = DateTime.now().subtract(const Duration(minutes: 1));
    await BabyStorage().saveProfile(
      BabyProfile(
        id: 'baby',
        name: 'Ada',
        gender: 'Female',
        birthDate: now.subtract(const Duration(days: 60)),
        weight: 5000,
        height: 55,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await inventory.addBatch(
      MilkBatch(
        id: 'milk',
        childId: 'baby',
        labelNumber: 'MILK-001',
        initialAmountMl: 150,
        remainingAmountMl: 150,
        expressedAt: now.subtract(const Duration(hours: 1)),
        storageLocation: MilkStorageLocation.refrigerator,
        sourceSide: MilkSourceSide.unspecified,
        createdAt: now,
      ),
    );
  });
  tearDown(SqliteTestSupport.tearDown);

  FeedingSession meal(
    int amount, {
    String? batchId = 'milk',
    BottleMilk type = BottleMilk.expressed,
  }) => FeedingSession(
    id: 'meal',
    childId: 'baby',
    startTime: now,
    endTime: now,
    entries: [],
    bottles: [
      BottlePortion(
        id: 'portion',
        milk: type,
        amountMl: amount,
        batchId: batchId,
      ),
    ],
  );

  test('legacy and mixed meals round trip without combining grams and ml', () {
    final old = FeedingSession.fromJson({
      'startTime': now.toIso8601String(),
      'endTime': now.toIso8601String(),
      'entries': [
        {'side': 'left', 'duration': 300},
      ],
      'milkIntakeGr': 15,
    });
    expect(old.bottles, isEmpty);
    final mixed = old.withBottles([
      BottlePortion(milk: BottleMilk.formula, amountMl: 60),
    ], note: 'top-up');
    final restored = FeedingSession.fromJson(mixed.toJson());
    expect(restored.totalDuration.inMinutes, 5);
    expect(restored.totalMilkIntake, 15);
    expect(restored.amountFor(BottleMilk.formula), 60);
    expect(restored.note, 'top-up');
  });

  test(
    'free manual bottles work but new inventory links require premium',
    () async {
      await storage.saveMeal(meal(60, batchId: null));
      await expectLater(storage.saveMeal(meal(60)), throwsStateError);
      expect(
        (await storage.loadSessions()).single.bottles.single.batchId,
        isNull,
      );
      expect((await inventory.loadBatches()).single.remainingAmountMl, 150);
    },
  );

  test(
    'atomic, idempotent save, correction, and deletion reconcile stock',
    () async {
      final first = meal(90);
      await storage.saveMeal(first, inventoryAccess: true);
      await storage.saveMeal(first, inventoryAccess: true);
      expect((await inventory.loadBatches()).single.remainingAmountMl, 60);
      expect(
        (await inventory.loadEvents()).where(
          (e) => e.type == MilkInventoryEventType.used,
        ),
        hasLength(1),
      );
      await storage.saveMeal(
        meal(50),
      ); // Corrections remain possible after subscription expiry.
      expect((await inventory.loadBatches()).single.remainingAmountMl, 100);
      await storage.deleteMeal(
        first,
      ); // Uses current persisted amount, not stale UI amount.
      expect(await storage.loadSessions(), isEmpty);
      expect((await inventory.loadBatches()).single.remainingAmountMl, 150);
      await storage.deleteMeal(first);
      expect((await inventory.loadBatches()).single.remainingAmountMl, 150);
    },
  );

  test('insufficient stock rolls back all portions and their events', () async {
    final invalid = meal(100).withBottles([
      BottlePortion(milk: BottleMilk.expressed, amountMl: 100, batchId: 'milk'),
      BottlePortion(milk: BottleMilk.expressed, amountMl: 60, batchId: 'milk'),
    ]);
    await expectLater(
      storage.saveMeal(invalid, inventoryAccess: true),
      throwsStateError,
    );
    expect(await storage.loadSessions(), isEmpty);
    expect((await inventory.loadBatches()).single.remainingAmountMl, 150);
    expect(await inventory.loadEvents(), hasLength(1));
  });

  test(
    'cannot link formula, expired stock, or another child inventory',
    () async {
      await expectLater(
        storage.saveMeal(
          meal(30, type: BottleMilk.formula),
          inventoryAccess: true,
        ),
        throwsStateError,
      );
      final batch = (await inventory.loadBatches()).single;
      await inventory.saveAll([
        batch.copyWith(expressedAt: now.subtract(const Duration(days: 5))),
      ]);
      await expectLater(
        storage.saveMeal(meal(30), inventoryAccess: true),
        throwsStateError,
      );
      await inventory.saveAll([batch.copyWith(childId: 'other')]);
      await expectLater(
        storage.saveMeal(meal(30), inventoryAccess: true),
        throwsStateError,
      );
      expect(await storage.loadSessions(), isEmpty);
    },
  );

  test(
    'latest breast query ignores any number of newer bottle meals',
    () async {
      final breast = FeedingSession(
        id: 'breast',
        childId: 'baby',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now,
        entries: [
          FeedingEntry(
            side: FeedingSide.left,
            duration: const Duration(minutes: 5),
          ),
        ],
      );
      await storage.saveMeal(breast);
      for (var i = 0; i < 12; i++) {
        await storage.saveMeal(
          FeedingSession(
            id: 'b$i',
            childId: 'baby',
            startTime: now,
            endTime: now,
            entries: [],
            bottles: [BottlePortion(milk: BottleMilk.formula, amountMl: 30)],
          ),
        );
      }
      expect((await storage.loadLatestBreastfeeding())!.id, 'breast');
      expect((await storage.loadLatestSession())!.id, isNot('breast'));
    },
  );

  test('backup preserves meal links without consuming stock twice', () async {
    await storage.saveMeal(meal(90), inventoryAccess: true);
    final backup = BackupService();
    final bytes = await backup.createBackup('test-password');
    final restore = await backup.prepareRestore(bytes, 'test-password');
    await ResetService.clearAll();
    await backup.restore(restore);
    final restored = (await storage.loadSessions()).single;
    expect(restored.bottles.single.batchId, 'milk');
    expect(restored.bottleAmountMl, 90);
    await storage.saveMeal(restored, inventoryAccess: true);
    expect((await inventory.loadBatches()).single.remainingAmountMl, 60);
  });

  test(
    'saving a completed meal clears only its own draft atomically',
    () async {
      final saved = meal(90);
      await storage.saveActiveDraft({'session': saved.toJson()});
      await storage.saveMeal(saved, inventoryAccess: true);
      expect(await storage.loadActiveDraft(), isNull);
      await storage.saveActiveDraft({
        'session': {'id': 'other-meal'},
      });
      await storage.saveMeal(saved, inventoryAccess: true);
      expect((await storage.loadActiveDraft())!['session']['id'], 'other-meal');
    },
  );

  test(
    'changing time cannot place a linked meal before milk was expressed',
    () async {
      final saved = meal(60);
      await storage.saveMeal(saved, inventoryAccess: true);
      await expectLater(
        storage.saveMeal(
          saved.withBottles(
            saved.bottles,
            time: now.subtract(const Duration(hours: 2)),
          ),
          inventoryAccess: true,
        ),
        throwsStateError,
      );
      expect((await storage.loadSessions()).single.startTime, now);
      expect((await inventory.loadBatches()).single.remainingAmountMl, 90);
    },
  );
}
