import 'dart:async';

import 'feeding_entry.dart';
import 'feeding_session.dart';

class FeedingController {
  FeedingSession? currentSession;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  final Function(Duration) onTick;

  FeedingSide? activeSide;
  DateTime? activeSideStartedAt;

  int? startWeightGr;
  int? endWeightGr;

  FeedingController({required this.onTick});

  void setStartWeight(int? weightGr) {
    startWeightGr = weightGr;
  }

  void setEndWeight(int? weightGr) {
    endWeightGr = weightGr;
  }

  void startSide(FeedingSide side, {DateTime? startedAt}) {
    final now = startedAt ?? DateTime.now();

    if (currentSession == null) {
      currentSession = FeedingSession(
        startTime: now,
        endTime: now,
        entries: [],
        startWeightGr: startWeightGr,
      );
    }

    activeSide = side;
    activeSideStartedAt = now;
    _elapsed = DateTime.now().difference(activeSideStartedAt!);
    onTick(_elapsed);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(activeSideStartedAt!);
      onTick(_elapsed);
    });
  }

  FeedingEntry stopSide(FeedingSide side) {
    _timer?.cancel();

    final elapsed = activeSideStartedAt == null
        ? _elapsed
        : DateTime.now().difference(activeSideStartedAt!);

    final entry = FeedingEntry(
      side: side,
      duration: elapsed,
    );

    currentSession!.entries.add(entry);
    activeSide = null;
    activeSideStartedAt = null;
    _elapsed = Duration.zero;

    return entry;
  }

  FeedingSession finishSession() {
    _timer?.cancel();

    final now = DateTime.now();

    final session = FeedingSession(
      startTime: currentSession!.startTime,
      endTime: now,
      entries: currentSession!.entries,
      startWeightGr: currentSession!.startWeightGr,
      endWeightGr: endWeightGr,
      milkIntakeGr: (currentSession!.startWeightGr != null &&
              endWeightGr != null)
          ? (endWeightGr! - currentSession!.startWeightGr!)
          : null,
    );

    currentSession = null;
    activeSide = null;
    activeSideStartedAt = null;
    _elapsed = Duration.zero;

    return session;
  }

  void restoreDraft({
    required FeedingSession session,
    required FeedingSide? draftActiveSide,
    required DateTime? draftActiveSideStartedAt,
    int? draftStartWeightGr,
    int? draftEndWeightGr,
  }) {
    _timer?.cancel();
    currentSession = session;
    startWeightGr = draftStartWeightGr;
    endWeightGr = draftEndWeightGr;
    activeSide = draftActiveSide;
    activeSideStartedAt = draftActiveSideStartedAt;

    if (activeSide != null && activeSideStartedAt != null) {
      _elapsed = DateTime.now().difference(activeSideStartedAt!);
      onTick(_elapsed);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _elapsed = DateTime.now().difference(activeSideStartedAt!);
        onTick(_elapsed);
      });
    } else {
      _elapsed = Duration.zero;
      onTick(_elapsed);
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
