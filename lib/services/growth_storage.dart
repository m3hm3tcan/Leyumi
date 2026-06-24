import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/growth_entry.dart';
import '../domain/repositories/growth_repository.dart';
import '../core/data/json_record_decoder.dart';

class GrowthStorage implements GrowthRepository {
  static const String key = "growth_history";

  Future<void> addEntry(GrowthEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    list.add(jsonEncode(entry.toJson()));

    await prefs.setStringList(key, list);
  }

  Future<List<GrowthEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    return JsonRecordDecoder.decodeStringList(
      values: list,
      fromJson: GrowthEntry.fromJson,
      source: 'growth',
    ).reversed.toList(); // en güncel en üstte
  }

  Future<void> saveAllEntries(List<GrowthEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();

    final list = entries.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList(key, list);
  }

  Future<void> deleteEntry(GrowthEntry entry) async {
    final entries = await loadEntries();

    entries.removeWhere((item) => item.id == entry.id);

    await saveAllEntries(entries);
  }
}
