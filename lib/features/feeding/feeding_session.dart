import 'feeding_entry.dart';

class FeedingSession {
  final DateTime startTime;
  final DateTime endTime;
  final List<FeedingEntry> entries;

  final int? startWeightGr;
  final int? endWeightGr;
  final int? milkIntakeGr;

  FeedingSession({
    required this.startTime,
    required this.endTime,
    required this.entries,
    this.startWeightGr,
    this.endWeightGr,
    this.milkIntakeGr,
  });

  // ─────────────────────────────
  // CORE METRICS
  // ─────────────────────────────

  Duration get totalDuration {
    return entries.fold(
      Duration.zero,
      (sum, e) => sum + e.duration,
    );
  }

  Duration get leftDuration {
    return entries
        .where((e) => e.side == FeedingSide.left)
        .fold(Duration.zero, (sum, e) => sum + e.duration);
  }

  Duration get rightDuration {
    return entries
        .where((e) => e.side == FeedingSide.right)
        .fold(Duration.zero, (sum, e) => sum + e.duration);
  }

  double get leftRatio {
    final total = totalDuration.inSeconds;
    if (total == 0) return 0.5;
    return leftDuration.inSeconds / total;
  }

  int get totalMilkIntake => milkIntakeGr ?? 0;

  bool get hasMilkData => milkIntakeGr != null && milkIntakeGr! > 0;

  bool get isLongSession => totalDuration.inMinutes > 30;

  DateTime get endTimeSafe =>
      entries.isNotEmpty ? endTime : startTime;

  // ─────────────────────────────
  // SERIALIZATION
  // ─────────────────────────────

  Map<String, dynamic> toJson() => {
        "startTime": startTime.toIso8601String(),
        "endTime": endTime.toIso8601String(),
        "entries": entries.map((e) => e.toJson()).toList(),
        "startWeightGr": startWeightGr,
        "endWeightGr": endWeightGr,
        "milkIntakeGr": milkIntakeGr,
      };

  factory FeedingSession.fromJson(Map<String, dynamic> json) {
    return FeedingSession(
      startTime: DateTime.parse(json["startTime"]),
      endTime: DateTime.parse(json["endTime"]),
      entries: (json["entries"] as List<dynamic>)
          .map((e) => FeedingEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      startWeightGr: json["startWeightGr"],
      endWeightGr: json["endWeightGr"],
      milkIntakeGr: json["milkIntakeGr"],
    );
  }
}