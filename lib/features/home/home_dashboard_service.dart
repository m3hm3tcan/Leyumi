import '../../core/database/app_database.dart';
import '../../core/database/sqlite_records.dart';
import '../../core/logging/app_logger.dart';
import '../diaper/diaper_entry.dart';
import '../feeding/feeding_session.dart';
import '../feeding/bottle_portion.dart';
import 'home_dashboard_snapshot.dart';

abstract interface class HomeDashboardLoader {
  Future<HomeDashboardSnapshot> load({required String childId, DateTime? now});
}

class HomeDashboardService implements HomeDashboardLoader {
  const HomeDashboardService();

  @override
  Future<HomeDashboardSnapshot> load({
    required String childId,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final dayStart = DateTime(reference.year, reference.month, reference.day);
    final nextDay = DateTime(
      reference.year,
      reference.month,
      reference.day + 1,
    );
    final db = await AppDatabase.instance;

    final results = await Future.wait([
      SqliteRecords.readPayloads(
        db,
        AppDatabase.feedingTable,
        childId: childId,
        from: dayStart,
        until: nextDay,
      ),
      SqliteRecords.readPayloads(
        db,
        AppDatabase.diaperTable,
        childId: childId,
        from: dayStart,
        until: nextDay,
      ),
      SqliteRecords.readPayloads(
        db,
        AppDatabase.feedingTable,
        childId: childId,
        descending: true,
        limit: 10,
      ),
      SqliteRecords.readPayloads(
        db,
        AppDatabase.diaperTable,
        childId: childId,
        descending: true,
        limit: 10,
      ),
    ]);

    final todayFeedings = _decodeFeedings(results[0]);
    final todayDiapers = _decodeDiapers(results[1]);
    final latestFeeding = _decodeFeedings(results[2]).firstOrNull;
    final latestDiaper = _decodeDiapers(results[3]).firstOrNull;

    return HomeDashboardSnapshot(
      todayFeedingCount: todayFeedings.length,
      todayFormulaMl: todayFeedings.fold(
        0,
        (sum, s) => sum + s.amountFor(BottleMilk.formula),
      ),
      todayExpressedMl: todayFeedings.fold(
        0,
        (sum, s) => sum + s.amountFor(BottleMilk.expressed),
      ),
      todayFeedingDuration: todayFeedings.fold(
        Duration.zero,
        (total, session) => total + session.totalDuration,
      ),
      todayDiaperCount: todayDiapers.length,
      todayPeeDiaperCount: todayDiapers
          .where(
            (entry) =>
                entry.type == DiaperType.pee || entry.type == DiaperType.both,
          )
          .length,
      todayPoopDiaperCount: todayDiapers
          .where(
            (entry) =>
                entry.type == DiaperType.poop || entry.type == DiaperType.both,
          )
          .length,
      lastFeeding: latestFeeding,
      lastDiaper: latestDiaper,
    );
  }

  List<FeedingSession> _decodeFeedings(List<Map<String, dynamic>> payloads) =>
      _decode(payloads, FeedingSession.fromJson, recordName: 'feeding');

  List<DiaperEntry> _decodeDiapers(List<Map<String, dynamic>> payloads) =>
      _decode(payloads, DiaperEntry.fromJson, recordName: 'diaper');

  List<T> _decode<T>(
    List<Map<String, dynamic>> payloads,
    T Function(Map<String, dynamic>) fromJson, {
    required String recordName,
  }) {
    final records = <T>[];
    for (final payload in payloads) {
      try {
        records.add(fromJson(payload));
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed $recordName dashboard record was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return records;
  }
}
