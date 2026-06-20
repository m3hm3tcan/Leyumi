import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/feeding/feeding_session.dart';

class FeedingStorage {
  static const String key = "feeding_sessions";
  static const String activeDraftKey = "feeding_active_draft";

  Future<void> saveSession(FeedingSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    list.add(jsonEncode(session.toJson()));

    await prefs.setStringList(key, list);
  }

  Future<List<FeedingSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    return list.map((item) {
      final data = jsonDecode(item);
      return FeedingSession.fromJson(data);
    }).toList();
  }

  Future<void> saveAllSessions(List<FeedingSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final data = sessions.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, data);
  }

  Future<void> saveActiveDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(activeDraftKey, jsonEncode(draft));
  }

  Future<Map<String, dynamic>?> loadActiveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(activeDraftKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearActiveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(activeDraftKey);
  }
}
