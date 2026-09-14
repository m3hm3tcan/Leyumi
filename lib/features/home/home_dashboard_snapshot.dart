import '../diaper/diaper_entry.dart';
import '../feeding/feeding_session.dart';

class HomeDashboardSnapshot {
  const HomeDashboardSnapshot({
    required this.todayFeedingCount,
    required this.todayFeedingDuration,
    required this.todayDiaperCount,
    required this.todayPeeDiaperCount,
    required this.todayPoopDiaperCount,
    this.todayFormulaMl = 0,
    this.todayExpressedMl = 0,
    this.lastFeeding,
    this.lastDiaper,
  });

  final int todayFeedingCount;
  final Duration todayFeedingDuration;
  final int todayDiaperCount;
  final int todayPeeDiaperCount;
  final int todayPoopDiaperCount;
  final int todayFormulaMl;
  final int todayExpressedMl;
  final FeedingSession? lastFeeding;
  final DiaperEntry? lastDiaper;

  bool get hasAnyRecord => lastFeeding != null || lastDiaper != null;

  DateTime? get lastActivity {
    final feedingTime = lastFeeding?.startTime;
    final diaperTime = lastDiaper?.timestamp;
    if (feedingTime == null) return diaperTime;
    if (diaperTime == null) return feedingTime;
    return feedingTime.isAfter(diaperTime) ? feedingTime : diaperTime;
  }
}
