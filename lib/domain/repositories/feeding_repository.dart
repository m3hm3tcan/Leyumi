import '../../features/feeding/feeding_session.dart';

abstract interface class FeedingRepository {
  Future<void> saveSession(FeedingSession session);
  Future<List<FeedingSession>> loadSessions();
  Future<void> saveAllSessions(List<FeedingSession> sessions);
  Future<void> saveActiveDraft(Map<String, dynamic> draft);
  Future<Map<String, dynamic>?> loadActiveDraft();
  Future<void> clearActiveDraft();
}
