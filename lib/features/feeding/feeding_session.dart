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

  Duration get totalDuration {
    Duration total = Duration.zero;
    for (var e in entries) {
      total += e.duration;
    }
    return total;
  }

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
      entries: (json["entries"] as List)
          .map((e) => FeedingEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      startWeightGr: json["startWeightGr"],
      endWeightGr: json["endWeightGr"],
      milkIntakeGr: json["milkIntakeGr"],
    );
  }
}
