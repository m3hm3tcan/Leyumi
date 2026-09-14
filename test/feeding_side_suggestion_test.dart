import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/features/feeding/feeding_side_suggestion.dart';

void main() {
  test('suggests the opposite of the latest recorded feeding side', () {
    final session = _session([
      FeedingEntry(
        side: FeedingSide.left,
        duration: const Duration(minutes: 8),
      ),
      FeedingEntry(
        side: FeedingSide.right,
        duration: const Duration(minutes: 5),
      ),
    ]);

    expect(FeedingSideSuggestion.nextFor(session), FeedingSide.left);
  });

  test('ignores empty entries and does not suggest without history', () {
    final session = _session([
      FeedingEntry(side: FeedingSide.left, duration: Duration.zero),
    ]);

    expect(FeedingSideSuggestion.nextFor(session), isNull);
    expect(FeedingSideSuggestion.nextFor(null), isNull);
  });
}

FeedingSession _session(List<FeedingEntry> entries) {
  final now = DateTime(2026, 8, 23, 20);
  return FeedingSession(
    childId: 'child-1',
    startTime: now,
    endTime: now,
    entries: entries,
    createdAt: now,
    updatedAt: now,
  );
}
