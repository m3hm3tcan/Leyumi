import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/growth_entry.dart';

class GrowthStorage {
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

    return list
        .map((e) => GrowthEntry.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList(); // en güncel en üstte
  }

  Future<void> saveAllEntries(List<GrowthEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();

    final list = entries
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(key, list);
  }

  Future<void> deleteEntry(GrowthEntry entry) async {
    final entries = await loadEntries();

    entries.removeWhere(
      (e) => e.date.toIso8601String() == entry.date.toIso8601String(),
    );

    await saveAllEntries(entries);
  }
}
