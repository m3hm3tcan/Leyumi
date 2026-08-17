import '../core/database/app_database.dart';
import '../core/database/sqlite_records.dart';
import '../core/logging/app_logger.dart';
import '../domain/repositories/growth_repository.dart';
import '../models/growth_entry.dart';
import 'active_child_scope.dart';

class GrowthStorage implements GrowthRepository {
  @override
  Future<void> addEntry(GrowthEntry entry) async {
    final db = await AppDatabase.instance;
    await SqliteRecords.upsert(
      db,
      AppDatabase.growthTable,
      id: entry.id,
      childId: entry.childId,
      sortTime: entry.date,
      payload: entry.toJson(),
    );
  }

  @override
  Future<List<GrowthEntry>> loadEntries() async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    final payloads = await SqliteRecords.readPayloads(
      db,
      AppDatabase.growthTable,
      childId: childId,
      descending: true,
    );
    final entries = <GrowthEntry>[];
    for (final payload in payloads) {
      try {
        entries.add(GrowthEntry.fromJson(payload));
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed growth record was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return entries;
  }

  @override
  Future<void> saveAllEntries(List<GrowthEntry> entries) async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    await SqliteRecords.replaceForChild(
      db,
      AppDatabase.growthTable,
      childId: childId,
      records: entries,
      idOf: (item) => item.id,
      childIdOf: (item) => item.childId,
      sortTimeOf: (item) => item.date,
      toJson: (item) => item.toJson(),
    );
  }

  @override
  Future<void> deleteEntry(GrowthEntry entry) async {
    final db = await AppDatabase.instance;
    await db.delete(
      AppDatabase.growthTable,
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }
}
