import 'dart:async';
import 'feeding_session.dart';
import 'feeding_entry.dart';

class FeedingController {
  FeedingSession? currentSession;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  final Function(Duration) onTick;

  FeedingController({required this.onTick});

  void startSide(String side) {
    if (currentSession == null) {
      currentSession = FeedingSession(
        startTime: DateTime.now(),
        entries: [],
      );
    }

    _elapsed = Duration.zero;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      onTick(_elapsed);
    });
  }

  FeedingEntry stopSide(String side) {
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
    currentSession!.endTime = DateTime.now();
    final session = currentSession!;
    currentSession = null;
    return session;
  }
}
