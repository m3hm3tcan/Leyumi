import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/diaper/diaper_entry.dart';

class DiaperStorage {
	static const String key = "diaper_history";

	Future<void> addEntry(DiaperEntry entry) async {
		final prefs = await SharedPreferences.getInstance();
		final list = prefs.getStringList(key) ?? [];

		list.add(jsonEncode(entry.toJson()));

		await prefs.setStringList(key, list);
	}

	Future<List<DiaperEntry>> loadEntries() async {
		final prefs = await SharedPreferences.getInstance();
		final list = prefs.getStringList(key) ?? [];

		return list
				.map((e) => DiaperEntry.fromJson(jsonDecode(e)))
				.toList()
				.reversed
				.toList(); // newest first
	}

	Future<void> saveAllEntries(List<DiaperEntry> entries) async {
		final prefs = await SharedPreferences.getInstance();

		final data = entries.map((e) => jsonEncode(e.toJson())).toList();

		await prefs.setStringList(key, data);
	}
}
