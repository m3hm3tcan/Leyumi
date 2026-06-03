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
}
