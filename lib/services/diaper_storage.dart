import '../core/database/app_database.dart';
import '../core/database/sqlite_records.dart';
import '../core/logging/app_logger.dart';
import '../domain/repositories/diaper_repository.dart';
import '../features/diaper/diaper_entry.dart';
import 'active_child_scope.dart';

class DiaperStorage implements DiaperRepository {
  @override
  Future<void> addEntry(DiaperEntry entry) async {
    final db = await AppDatabase.instance;
    await SqliteRecords.upsert(
      db,
      AppDatabase.diaperTable,
      id: entry.id,
      childId: entry.childId,
      sortTime: entry.timestamp,
      payload: entry.toJson(),
    );
  }

  @override
  Future<List<DiaperEntry>> loadEntries() async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    final payloads = await SqliteRecords.readPayloads(
      db,
      AppDatabase.diaperTable,
      childId: childId,
      descending: true,
    );
    final entries = <DiaperEntry>[];
    for (final payload in payloads) {
      try {
        entries.add(DiaperEntry.fromJson(payload));
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed diaper record was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return entries;
  }

  @override
  Future<void> saveAllEntries(List<DiaperEntry> entries) async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    await SqliteRecords.replaceForChild(
      db,
      AppDatabase.diaperTable,
      childId: childId,
      records: entries,
      idOf: (item) => item.id,
      childIdOf: (item) => item.childId,
      sortTimeOf: (item) => item.timestamp,
      toJson: (item) => item.toJson(),
    );
  }
}
