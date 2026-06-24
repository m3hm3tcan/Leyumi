import '../../domain/repositories/feeding_repository.dart';
import '../../services/feeding_storage.dart';
import 'feeding_controller.dart';
import 'feeding_entry.dart';
import 'feeding_session.dart';

class FeedingDraftState {
  const FeedingDraftState({
    required this.activeSide,
    required this.activeSideStartedAt,
    required this.startWeightGr,
    required this.endWeightGr,
  });

  final FeedingSide? activeSide;
  final DateTime? activeSideStartedAt;
  final int? startWeightGr;
  final int? endWeightGr;
}

class FeedingDraftService {
  FeedingDraftService({FeedingRepository? repository})
    : _repository = repository ?? FeedingStorage();

  final FeedingRepository _repository;

  Future<FeedingDraftState?> restore(FeedingController controller) async {
    final draft = await _repository.loadActiveDraft();
    if (draft == null) return null;

    final rawSession = draft['session'];
    if (rawSession is! Map) return null;

    final session = FeedingSession.fromJson(
      Map<String, dynamic>.from(rawSession),
    );
    final activeSide = _sideFromName(draft['activeSide'] as String?);
    final activeStartedAtRaw = draft['activeSideStartedAt'] as String?;
    final activeStartedAt = activeStartedAtRaw == null
        ? null
        : DateTime.tryParse(activeStartedAtRaw);
    final startWeight = _readInt(draft['startWeightGr']);
    final endWeight = _readInt(draft['endWeightGr']);

    controller.restoreDraft(
      session: session,
      draftActiveSide: activeSide,
      draftActiveSideStartedAt: activeStartedAt,
      draftStartWeightGr: startWeight,
      draftEndWeightGr: endWeight,
    );

    return FeedingDraftState(
      activeSide: activeSide,
      activeSideStartedAt: activeStartedAt,
      startWeightGr: startWeight,
      endWeightGr: endWeight,
    );
  }

  Future<void> persist(FeedingController controller) async {
    final session = controller.currentSession;
    if (session == null) {
      await clear();
      return;
    }

    await _repository.saveActiveDraft({
      'session': session.toJson(),
      'activeSide': controller.activeSide?.name,
      'activeSideStartedAt': controller.activeSideStartedAt?.toIso8601String(),
      'startWeightGr': controller.startWeightGr,
      'endWeightGr': controller.endWeightGr,
    });
  }

  Future<void> clear() => _repository.clearActiveDraft();

  FeedingSide? _sideFromName(String? value) {
    return switch (value) {
      'left' => FeedingSide.left,
      'right' => FeedingSide.right,
      _ => null,
    };
  }

  int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }
}
