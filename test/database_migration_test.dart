import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/core/database/app_database.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('upgrades a version 1 database without losing profiles', () async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp(
      'leyumi_migration_test_',
    );
    final databasePath = path.join(directory.path, AppDatabase.fileName);

    addTearDown(() async {
      await AppDatabase.close();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final versionOne = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (database, _) async {
          await database.execute('''
            CREATE TABLE ${AppDatabase.profilesTable} (
              id TEXT PRIMARY KEY NOT NULL,
              sort_time INTEGER NOT NULL,
              payload TEXT NOT NULL
            )
          ''');
          await database.insert(AppDatabase.profilesTable, {
            'id': 'child-1',
            'sort_time': 1,
            'payload': '{}',
          });
        },
      ),
    );
    await versionOne.close();

    await AppDatabase.configureForTesting(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    final upgraded = await AppDatabase.instance;

    expect(await upgraded.getVersion(), AppDatabase.schemaVersion);
    expect(await upgraded.query(AppDatabase.profilesTable), hasLength(1));
    final indexes = await upgraded.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index' AND name = ?",
      ['${AppDatabase.profilesTable}_sort_idx'],
    );
    expect(indexes, hasLength(1));
  });
}
