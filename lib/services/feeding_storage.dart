import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/feeding/feeding_session.dart';
import '../domain/repositories/feeding_repository.dart';
import '../core/data/json_record_decoder.dart';
import '../core/logging/app_logger.dart';
import 'active_child_scope.dart';

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
    final sessions = await _loadAllSessions();
    return ActiveChildScope.filter(sessions, (session) => session.childId);
  }

  Future<List<FeedingSession>> _loadAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];

    return JsonRecordDecoder.decodeStringList(
      values: list,
      fromJson: FeedingSession.fromJson,
      source: 'feeding',
    );
  }

  Future<void> saveAllSessions(List<FeedingSession> sessions) async {
    final activeId = await ActiveChildScope.id();
    final allSessions = await _loadAllSessions();
    final merged = activeId == null
        ? sessions
        : [
            ...allSessions.where((session) => session.childId != activeId),
            ...sessions,
          ];
    final prefs = await SharedPreferences.getInstance();
    final data = merged.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, data);
  }

  Future<void> saveActiveDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _draftKey(), jsonEncode(draft));
  }

  Future<Map<String, dynamic>?> loadActiveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = await _draftKey();
    var raw = prefs.getString(scopedKey);
    if (raw == null && scopedKey != activeDraftKey) {
      raw = prefs.getString(activeDraftKey);
    }
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
    await prefs.remove(await _draftKey());
  }

  Future<void> deleteChildData(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await _loadAllSessions();
    final remaining = sessions
        .where((session) => session.childId != childId)
        .map((session) => jsonEncode(session.toJson()))
        .toList();
    await prefs.setStringList(key, remaining);
    await prefs.remove('${activeDraftKey}_$childId');

    final legacyDraft = prefs.getString(activeDraftKey);
    if (legacyDraft == null || legacyDraft.isEmpty) return;
    try {
      final draft = Map<String, dynamic>.from(jsonDecode(legacyDraft) as Map);
      final session = draft['session'];
      if (session is Map && session['childId'] == childId) {
        await prefs.remove(activeDraftKey);
      }
    } catch (_) {
      // Keep malformed legacy data untouched; normal decoder logging handles it.
    }
  }

  Future<String> _draftKey() async {
    final childId = await ActiveChildScope.id();
    return childId == null ? activeDraftKey : '${activeDraftKey}_$childId';
  }
}
