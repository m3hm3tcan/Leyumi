import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/record_identity.dart';
import '../core/logging/app_logger.dart';
import 'baby_storage.dart';
import 'diaper_storage.dart';
import 'feeding_storage.dart';
import 'growth_storage.dart';
import 'milk_inventory_storage.dart';

class ChildDataMigrationService {
  static const migrationKey = 'child_data_migration_v1';

  Future<void> migrateIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(migrationKey) ?? false) return;

    final profile = await BabyStorage().loadProfile();
    if (profile == null) return;

    await _safely(
      'feeding records',
      () => _migrateStringList(
        preferences,
        key: FeedingStorage.key,
        childId: profile.id,
      ),
    );
    await _safely(
      'diaper records',
      () => _migrateStringList(
        preferences,
        key: DiaperStorage.key,
        childId: profile.id,
      ),
    );
    await _safely(
      'growth records',
      () => _migrateStringList(
        preferences,
        key: GrowthStorage.key,
        childId: profile.id,
      ),
    );
    await _safely(
      'milk batches',
      () => _migrateJsonArray(
        preferences,
        key: MilkInventoryStorage.key,
        childId: profile.id,
      ),
    );
    await _safely(
      'milk events',
      () => _migrateJsonArray(
        preferences,
        key: MilkInventoryStorage.eventKey,
        childId: profile.id,
      ),
    );
    await _safely(
      'feeding draft',
      () => _migrateDraft(preferences, profile.id),
    );
    await preferences.setBool(migrationKey, true);
  }

  Future<void> _migrateStringList(
    SharedPreferences preferences, {
    required String key,
    required String childId,
  }) async {
    final values = preferences.getStringList(key);
    if (values == null) return;
    final migrated = values.map((value) {
      try {
        final json = Map<String, dynamic>.from(jsonDecode(value) as Map);
        _replaceLegacyChildId(json, childId);
        return jsonEncode(json);
      } catch (_) {
        return value;
      }
    }).toList();
    await preferences.setStringList(key, migrated);
  }

  Future<void> _migrateJsonArray(
    SharedPreferences preferences, {
    required String key,
    required String childId,
  }) async {
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    final values = <dynamic>[];
    for (final item in decoded) {
      try {
        final value = Map<String, dynamic>.from(item as Map);
        _replaceLegacyChildId(value, childId);
        values.add(value);
      } catch (_) {
        values.add(item);
      }
    }
    await preferences.setString(key, jsonEncode(values));
  }

  Future<void> _migrateDraft(
    SharedPreferences preferences,
    String childId,
  ) async {
    final raw = preferences.getString(FeedingStorage.activeDraftKey);
    if (raw == null || raw.isEmpty) return;
    final draft = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final session = draft['session'];
    if (session is Map) {
      final sessionJson = Map<String, dynamic>.from(session);
      _replaceLegacyChildId(sessionJson, childId);
      draft['session'] = sessionJson;
      await preferences.setString(
        '${FeedingStorage.activeDraftKey}_$childId',
        jsonEncode(draft),
      );
      await preferences.remove(FeedingStorage.activeDraftKey);
    }
  }

  void _replaceLegacyChildId(Map<String, dynamic> json, String childId) {
    final current = json['childId'] as String?;
    if (current == null ||
        current.isEmpty ||
        current == RecordIdentity.legacyChildId) {
      json['childId'] = childId;
    }
  }

  Future<void> _safely(String source, Future<void> Function() migration) async {
    try {
      await migration();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Child migration skipped malformed $source.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
