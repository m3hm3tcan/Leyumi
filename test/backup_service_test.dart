import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/models/baby_profile.dart';
import 'package:leyumi/services/backup_service.dart';
import 'package:leyumi/services/baby_storage.dart';
import 'package:leyumi/services/diaper_storage.dart';
import 'package:leyumi/services/reset_service.dart';

import 'sqlite_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(SqliteTestSupport.setUp);
  tearDown(SqliteTestSupport.tearDown);

  test('encrypts and restores every child record', () async {
    final now = DateTime.utc(2026, 8, 20, 12);
    final babies = BabyStorage();
    final diapers = DiaperStorage();
    await babies.saveProfile(_profile('child-1', 'Ada', now));
    await diapers.addEntry(
      DiaperEntry(
        id: 'diaper-1',
        childId: 'child-1',
        timestamp: now,
        type: DiaperType.both,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final service = BackupService();

    final encrypted = await service.createBackup('strong-password');

    expect(utf8.decode(encrypted), isNot(contains('Ada')));
    final plan = await service.prepareRestore(encrypted, 'strong-password');
    expect(plan.preview.profileCount, 1);
    expect(plan.preview.recordCount, 1);

    await ResetService.clearAll();
    await babies.saveProfile(_profile('child-2', 'Mira', now));
    await service.restore(plan);

    expect((await babies.loadProfiles()).single.name, 'Ada');
    expect((await diapers.loadEntries()).single.id, 'diaper-1');
  });

  test('rejects an incorrect backup password', () async {
    final now = DateTime.utc(2026, 8, 20, 12);
    await BabyStorage().saveProfile(_profile('child-1', 'Ada', now));
    final service = BackupService();
    final encrypted = await service.createBackup('strong-password');

    await expectLater(
      service.prepareRestore(encrypted, 'wrong-password'),
      throwsA(
        isA<BackupException>().having(
          (error) => error.failure,
          'failure',
          BackupFailure.invalidPassword,
        ),
      ),
    );
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
