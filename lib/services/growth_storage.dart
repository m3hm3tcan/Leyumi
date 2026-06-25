import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/json_record_decoder.dart';
import '../domain/repositories/growth_repository.dart';
import '../models/growth_entry.dart';
import 'active_child_scope.dart';

class GrowthStorage implements GrowthRepository {
  static const String key = 'growth_history';

  @override
  Future<void> addEntry(GrowthEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    list.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(key, list);
  }

  @override
  Future<List<GrowthEntry>> loadEntries() async {
    final entries = await _loadAllEntries();
    final filtered = await ActiveChildScope.filter(
      entries,
      (entry) => entry.childId,
    );
    return filtered.reversed.toList();
  }

  Future<List<GrowthEntry>> _loadAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    return JsonRecordDecoder.decodeStringList(
      values: prefs.getStringList(key) ?? [],
      fromJson: GrowthEntry.fromJson,
      source: 'growth',
    );
  }

  @override
  Future<void> saveAllEntries(List<GrowthEntry> entries) async {
    final activeId = await ActiveChildScope.id();
    final allEntries = await _loadAllEntries();
    final normalized = entries.reversed.toList();
    final merged = activeId == null
        ? normalized
        : [
            ...allEntries.where((entry) => entry.childId != activeId),
            ...normalized,
          ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      merged.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }

  @override
  Future<void> deleteEntry(GrowthEntry entry) async {
    final entries = await loadEntries();
    entries.removeWhere((item) => item.id == entry.id);
    await saveAllEntries(entries);
  }

  Future<void> deleteChildData(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await _loadAllEntries();
    final remaining = entries
        .where((entry) => entry.childId != childId)
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList(key, remaining);
  }
}
