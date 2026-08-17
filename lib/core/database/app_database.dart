import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Owns Leyumi's durable, transactional application database.
///
/// Preferences such as theme selection remain in SharedPreferences. Child and
/// care records belong in this database because they must survive atomic writes
/// and grow beyond the limits of a key-value preference store.
class AppDatabase {
  AppDatabase._();

  static const fileName = 'leyumi.db';
  static const schemaVersion = 1;

  static const profilesTable = 'baby_profiles';
  static const feedingTable = 'feeding_sessions';
  static const diaperTable = 'diaper_entries';
  static const growthTable = 'growth_entries';
  static const milkBatchesTable = 'milk_batches';
  static const milkEventsTable = 'milk_inventory_events';
  static const careEventsTable = 'care_events';
  static const feedingDraftsTable = 'feeding_drafts';
  static const metadataTable = 'app_metadata';

  static DatabaseFactory _factory = databaseFactory;
  static String? _pathOverride;
  static Database? _database;

  static Future<Database> get instance async {
    final existing = _database;
    if (existing != null) return existing;

    final databasePath =
        _pathOverride ?? path.join(await _factory.getDatabasesPath(), fileName);
    final opened = await _factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _createSchema,
      ),
    );
    _database = opened;
    return opened;
  }

  static Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $profilesTable (
        id TEXT PRIMARY KEY NOT NULL,
        sort_time INTEGER NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
    for (final table in recordTables) {
      await db.execute('''
        CREATE TABLE $table (
          id TEXT PRIMARY KEY NOT NULL,
          child_id TEXT NOT NULL,
          sort_time INTEGER NOT NULL,
          payload TEXT NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX ${table}_child_sort_idx '
        'ON $table(child_id, sort_time)',
      );
    }
    await db.execute('''
      CREATE TABLE $feedingDraftsTable (
        child_id TEXT PRIMARY KEY NOT NULL,
        payload TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $metadataTable (
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT NOT NULL
      )
    ''');
  }

  static const recordTables = <String>[
    feedingTable,
    diaperTable,
    growthTable,
    milkBatchesTable,
    milkEventsTable,
    careEventsTable,
  ];

  static Future<void> deleteAllData() async {
    final db = await instance;
    await db.transaction((txn) async {
      await txn.delete(feedingDraftsTable);
      for (final table in recordTables) {
        await txn.delete(table);
      }
      await txn.delete(profilesTable);
      await txn.delete(metadataTable);
    });
  }

  /// Test-only injection point. Production code always uses sqflite's mobile
  /// database factory and the private application database directory.
  static Future<void> configureForTesting({
    required DatabaseFactory factory,
    required String databasePath,
  }) async {
    await close();
    _factory = factory;
    _pathOverride = databasePath;
  }

  static Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) await db.close();
  }
}
