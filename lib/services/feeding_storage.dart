import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/sqlite_records.dart';
import '../core/logging/app_logger.dart';
import '../domain/repositories/feeding_repository.dart';
import '../features/feeding/feeding_session.dart';
import 'active_child_scope.dart';
import 'feeding_inventory_link.dart';

class FeedingStorage implements FeedingRepository {
  @override
  Future<void> saveSession(FeedingSession session) async {
    await saveMeal(session);
  }

  Future<void> saveMeal(
    FeedingSession session, {
    bool inventoryAccess = false,
  }) async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    if (childId != null && childId != session.childId) {
      throw StateError('Active child changed');
    }
    await db.transaction(
      (txn) => _save(txn, session, inventoryAccess: inventoryAccess),
    );
  }

  Future<FeedingSession?> _find(DatabaseExecutor db, String id) async {
    final rows = await db.query(
      AppDatabase.feedingTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return FeedingSession.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(rows.single['payload'] as String) as Map,
      ),
    );
  }

  Future<void> _save(
    DatabaseExecutor db,
    FeedingSession session, {
    bool inventoryAccess = false,
  }) async {
    await FeedingInventoryLink.reconcile(
      db,
      before: await _find(db, session.id),
      after: session,
      inventoryAccess: inventoryAccess,
    );
    await SqliteRecords.upsert(
      db,
      AppDatabase.feedingTable,
      id: session.id,
      childId: session.childId,
      sortTime: session.startTime,
      payload: session.toJson(),
    );
    final drafts = await db.query(
      AppDatabase.feedingDraftsTable,
      where: 'child_id = ?',
      whereArgs: [session.childId],
      limit: 1,
    );
    if (drafts.isNotEmpty) {
      final draft = jsonDecode(drafts.single['payload'] as String);
      if (draft is Map &&
          draft['session'] is Map &&
          draft['session']['id'] == session.id) {
        await db.delete(
          AppDatabase.feedingDraftsTable,
          where: 'child_id = ?',
          whereArgs: [session.childId],
        );
      }
    }
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

  Future<FeedingSession?> loadLatestBreastfeeding({String? childId}) async {
    final db = await AppDatabase.instance;
    final records = await _load(
      db,
      childId: childId ?? await ActiveChildScope.id(),
    );
    final breast = records.where((s) => s.hasBreastfeeding).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return breast.firstOrNull;
  }

  Future<void> deleteMeal(FeedingSession session) async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    if (childId != null && childId != session.childId) {
      throw StateError('Active child changed');
    }
    await db.transaction((txn) async {
      final current = await _find(txn, session.id);
      if (current == null) return;
      await FeedingInventoryLink.reconcile(
        txn,
        before: current,
        after: null,
        inventoryAccess: false,
      );
      await txn.delete(
        AppDatabase.feedingTable,
        where: 'id = ?',
        whereArgs: [session.id],
      );
    });
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
    await db.transaction((txn) async {
      final old = await _load(txn, childId: childId);
      final ids = sessions.map((s) => s.id).toSet();
      for (final session in old.where((s) => !ids.contains(s.id))) {
        await FeedingInventoryLink.reconcile(
          txn,
          before: session,
          after: null,
          inventoryAccess: false,
        );
        await txn.delete(
          AppDatabase.feedingTable,
          where: 'id = ?',
          whereArgs: [session.id],
        );
      }
      for (final session in sessions) {
        if (childId != null && session.childId != childId) {
          throw StateError('Active child changed');
        }
        await _save(txn, session);
      }
    });
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
