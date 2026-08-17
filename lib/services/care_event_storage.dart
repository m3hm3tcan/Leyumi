import '../core/database/app_database.dart';
import '../core/database/sqlite_records.dart';
import '../core/logging/app_logger.dart';
import '../features/care_calendar/care_event.dart';
import 'active_child_scope.dart';

class CareEventStorage {
  Future<List<CareEvent>> loadEvents() async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    final payloads = await SqliteRecords.readPayloads(
      db,
      AppDatabase.careEventsTable,
      childId: childId,
    );
    final events = <CareEvent>[];
    for (final payload in payloads) {
      try {
        events.add(CareEvent.fromJson(payload));
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed care event was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return events;
  }

  Future<void> save(CareEvent event) async {
    final db = await AppDatabase.instance;
    await SqliteRecords.upsert(
      db,
      AppDatabase.careEventsTable,
      id: event.id,
      childId: event.childId,
      sortTime: event.scheduledAt,
      payload: event.toJson(),
    );
  }

  Future<void> delete(String eventId) async {
    final db = await AppDatabase.instance;
    await db.delete(
      AppDatabase.careEventsTable,
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }
}
