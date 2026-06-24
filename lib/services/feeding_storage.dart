import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/feeding/feeding_session.dart';
import '../domain/repositories/feeding_repository.dart';
import '../core/data/json_record_decoder.dart';
import '../core/logging/app_logger.dart';

class FeedingStorage implements FeedingRepository {
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

    return JsonRecordDecoder.decodeStringList(
      values: list,
      fromJson: FeedingSession.fromJson,
      source: 'feeding',
    );
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
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'The active feeding draft could not be read.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> clearActiveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(activeDraftKey);
  }
}
