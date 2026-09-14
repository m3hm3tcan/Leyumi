import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../logging/app_logger.dart';

abstract final class SqliteRecords {
  static Future<List<Map<String, dynamic>>> readPayloads(
    DatabaseExecutor db,
    String table, {
    String? childId,
    DateTime? from,
    DateTime? until,
    bool descending = false,
    int? limit,
  }) async {
    final predicates = <String>[];
    final arguments = <Object>[];
    if (childId != null) {
      predicates.add('child_id = ?');
      arguments.add(childId);
    }
    if (from != null) {
      predicates.add('sort_time >= ?');
      arguments.add(from.microsecondsSinceEpoch);
    }
    if (until != null) {
      predicates.add('sort_time < ?');
      arguments.add(until.microsecondsSinceEpoch);
    }
    final rows = await db.query(
      table,
      columns: const ['payload'],
      where: predicates.isEmpty ? null : predicates.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'sort_time ${descending ? 'DESC' : 'ASC'}, rowid ASC',
      limit: limit,
    );
    final payloads = <Map<String, dynamic>>[];
    for (final row in rows) {
      try {
        payloads.add(
          Map<String, dynamic>.from(
            jsonDecode(row['payload']! as String) as Map,
          ),
        );
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed SQLite record in $table was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return payloads;
  }

  static Future<void> upsert(
    DatabaseExecutor db,
    String table, {
    required String id,
    required String? childId,
    required DateTime sortTime,
    required Map<String, dynamic> payload,
  }) async {
    await db.insert(table, {
      'id': id,
      'child_id': ?childId,
      'sort_time': sortTime.microsecondsSinceEpoch,
      'payload': jsonEncode(payload),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> replaceForChild<T>(
    Database db,
    String table, {
    required String? childId,
    required Iterable<T> records,
    required String Function(T) idOf,
    required String Function(T) childIdOf,
    required DateTime Function(T) sortTimeOf,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    await db.transaction((txn) async {
      if (childId == null) {
        await txn.delete(table);
      } else {
        await txn.delete(table, where: 'child_id = ?', whereArgs: [childId]);
      }
      for (final record in records) {
        await upsert(
          txn,
          table,
          id: idOf(record),
          childId: childIdOf(record),
          sortTime: sortTimeOf(record),
          payload: toJson(record),
        );
      }
    });
  }
}
