import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/sqlite_records.dart';
import '../core/logging/app_logger.dart';
import '../domain/repositories/feeding_repository.dart';
import '../features/feeding/feeding_session.dart';
import 'active_child_scope.dart';

class FeedingStorage implements FeedingRepository {
  @override
  Future<void> saveSession(FeedingSession session) async {
    final db = await AppDatabase.instance;
    await SqliteRecords.upsert(
      db,
      AppDatabase.feedingTable,
      id: session.id,
      childId: session.childId,
      sortTime: session.startTime,
      payload: session.toJson(),
    );
  }

  @override
  Future<List<FeedingSession>> loadSessions() async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    return _load(db, childId: childId);
  }

  @override
  Future<FeedingSession?> loadLatestSession({String? childId}) async {
    final db = await AppDatabase.instance;
    final resolvedChildId = childId ?? await ActiveChildScope.id();
    final payloads = await SqliteRecords.readPayloads(
      db,
      AppDatabase.feedingTable,
      childId: resolvedChildId,
      descending: true,
      limit: 10,
    );
    return _decode(payloads).firstOrNull;
  }

  Future<List<FeedingSession>> _load(
    DatabaseExecutor db, {
    String? childId,
  }) async {
    final payloads = await SqliteRecords.readPayloads(
      db,
      AppDatabase.feedingTable,
      childId: childId,
    );
    return _decode(payloads);
  }

  @override
  Future<void> saveAllSessions(List<FeedingSession> sessions) async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    await SqliteRecords.replaceForChild(
      db,
      AppDatabase.feedingTable,
      childId: childId,
      records: sessions,
      idOf: (item) => item.id,
      childIdOf: (item) => item.childId,
      sortTimeOf: (item) => item.startTime,
      toJson: (item) => item.toJson(),
    );
  }

  @override
  Future<void> saveActiveDraft(Map<String, dynamic> draft) async {
    final childId = await ActiveChildScope.id();
    if (childId == null) return;
    final db = await AppDatabase.instance;
    await db.insert(AppDatabase.feedingDraftsTable, {
      'child_id': childId,
      'payload': jsonEncode(draft),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<Map<String, dynamic>?> loadActiveDraft() async {
    final childId = await ActiveChildScope.id();
    if (childId == null) return null;
    final db = await AppDatabase.instance;
    final rows = await db.query(
      AppDatabase.feedingDraftsTable,
      columns: const ['payload'],
      where: 'child_id = ?',
      whereArgs: [childId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(
        jsonDecode(rows.first['payload']! as String) as Map,
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'The active feeding draft could not be read.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> clearActiveDraft() async {
    final childId = await ActiveChildScope.id();
    if (childId == null) return;
    final db = await AppDatabase.instance;
    await db.delete(
      AppDatabase.feedingDraftsTable,
      where: 'child_id = ?',
      whereArgs: [childId],
    );
  }

  List<FeedingSession> _decode(List<Map<String, dynamic>> payloads) {
    final result = <FeedingSession>[];
    for (final payload in payloads) {
      try {
        result.add(FeedingSession.fromJson(payload));
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed feeding record was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return result;
  }
}
