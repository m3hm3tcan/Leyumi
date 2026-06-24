import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/diaper/diaper_entry.dart';
import '../domain/repositories/diaper_repository.dart';
import '../core/data/json_record_decoder.dart';
import 'active_child_scope.dart';

class DiaperStorage implements DiaperRepository {
  static const String key = "diaper_history";

  Future<void> addEntry(DiaperEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    list.add(jsonEncode(entry.toJson()));

    await prefs.setStringList(key, list);
  }

  Future<List<DiaperEntry>> loadEntries() async {
    final entries = await _loadAllEntries();
    final filtered = await ActiveChildScope.filter(
      entries,
      (entry) => entry.childId,
    );
    return filtered.reversed.toList();
  }

  Future<List<DiaperEntry>> _loadAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    return JsonRecordDecoder.decodeStringList(
      values: list,
      fromJson: DiaperEntry.fromJson,
      source: 'diaper',
    );
  }

  Future<void> saveAllEntries(List<DiaperEntry> entries) async {
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

    final data = merged.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList(key, data);
  }
}
