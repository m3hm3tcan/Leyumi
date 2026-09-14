import 'feeding_entry.dart';
import 'feeding_session.dart';

abstract final class FeedingSideSuggestion {
  static FeedingSide? nextFor(FeedingSession? session) {
    if (session == null) return null;
    for (final entry in session.entries.reversed) {
      if (entry.duration <= Duration.zero) continue;
      return entry.side == FeedingSide.left
          ? FeedingSide.right
          : FeedingSide.left;
    }
    return null;
  }
}
