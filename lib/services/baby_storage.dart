import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/sqlite_records.dart';
import '../core/logging/app_logger.dart';
import '../domain/repositories/baby_repository.dart';
import '../models/baby_profile.dart';

class BabyStorage implements BabyRepository {
  static const _activeProfileKey = 'active_baby_profile_id';

  @override
  Future<void> saveProfile(BabyProfile profile) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      await SqliteRecords.upsert(
        txn,
        AppDatabase.profilesTable,
        id: profile.id,
        childId: null,
        sortTime: profile.createdAt,
        payload: profile.toJson(),
      );
      final active = await _loadMetadata(txn, _activeProfileKey);
      if (active == null) {
        await _saveMetadata(txn, _activeProfileKey, profile.id);
      }
    });
  }

  @override
  Future<BabyProfile?> loadProfile() async {
    final profiles = await loadProfiles();
    if (profiles.isEmpty) return null;
    final activeId = await loadActiveProfileId();
    return profiles.where((profile) => profile.id == activeId).firstOrNull ??
        profiles.first;
  }

  @override
  Future<List<BabyProfile>> loadProfiles() async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      AppDatabase.profilesTable,
      columns: const ['payload'],
      orderBy: 'sort_time ASC, rowid ASC',
    );
    final profiles = <BabyProfile>[];
    for (final row in rows) {
      try {
        profiles.add(
          BabyProfile.fromJson(
            Map<String, dynamic>.from(
              jsonDecode(row['payload']! as String) as Map,
            ),
          ),
        );
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed baby profile was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return profiles;
  }

  @override
  Future<void> setActiveProfile(String profileId) async {
    final db = await AppDatabase.instance;
    final exists =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${AppDatabase.profilesTable} WHERE id = ?',
            [profileId],
          ),
        ) ==
        1;
    if (!exists) return;
    await _saveMetadata(db, _activeProfileKey, profileId);
  }

  @override
  Future<String?> loadActiveProfileId() async {
    final db = await AppDatabase.instance;
    return _loadMetadata(db, _activeProfileKey);
  }

  @override
  Future<void> deleteProfile(String profileId) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      for (final table in AppDatabase.recordTables) {
        await txn.delete(table, where: 'child_id = ?', whereArgs: [profileId]);
      }
      await txn.delete(
        AppDatabase.feedingDraftsTable,
        where: 'child_id = ?',
        whereArgs: [profileId],
      );
      await txn.delete(
        AppDatabase.profilesTable,
        where: 'id = ?',
        whereArgs: [profileId],
      );
      final active = await _loadMetadata(txn, _activeProfileKey);
      if (active != profileId) return;
      final remaining = await txn.query(
        AppDatabase.profilesTable,
        columns: const ['id'],
        orderBy: 'sort_time ASC, rowid ASC',
        limit: 1,
      );
      if (remaining.isEmpty) {
        await txn.delete(
          AppDatabase.metadataTable,
          where: 'key = ?',
          whereArgs: [_activeProfileKey],
        );
      } else {
        await _saveMetadata(
          txn,
          _activeProfileKey,
          remaining.first['id']! as String,
        );
      }
    });
  }

  static Future<String?> _loadMetadata(DatabaseExecutor db, String key) async {
    final rows = await db.query(
      AppDatabase.metadataTable,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value']! as String;
  }

  static Future<void> _saveMetadata(
    DatabaseExecutor db,
    String key,
    String value,
  ) async {
    await db.insert(AppDatabase.metadataTable, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
