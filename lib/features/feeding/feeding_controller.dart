import 'dart:async';
import 'feeding_session.dart';
import 'feeding_entry.dart';

class FeedingController {
  FeedingSession? currentSession;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  final Function(Duration) onTick;

  int? startWeightGr; // Feeding öncesi kilo
  int? endWeightGr;   // Feeding sonrası kilo

  FeedingController({required this.onTick});

  void setStartWeight(int? weightGr) {
    startWeightGr = weightGr;
  }

  void setEndWeight(int? weightGr) {
    endWeightGr = weightGr;
  }

  void startSide(FeedingSide  side) {
    if (currentSession == null) {
      currentSession = FeedingSession(
        startTime: DateTime.now(),
        endTime: DateTime.now(), // geçici, finishSession'da override edeceğiz
        entries: [],
        startWeightGr: startWeightGr,
      );
    }

    _elapsed = Duration.zero;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      onTick(_elapsed);
    });
  }

  FeedingEntry stopSide(FeedingSide side) {
    _timer?.cancel();

    final entry = FeedingEntry(
      side: side,
      duration: _elapsed,
    );

    currentSession!.entries.add(entry);

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
    return session;
  }
}
