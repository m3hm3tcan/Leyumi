import 'feeding_entry.dart';

class FeedingSession {
  final DateTime startTime;
  DateTime? endTime;
  final List<FeedingEntry> entries;

  FeedingSession({
    required this.startTime,
    required this.entries,
    this.endTime,
  });

  Duration get totalDuration {
    return entries.fold(Duration.zero, (sum, e) => sum + e.duration);
  }

  Map<String, dynamic> toJson() => {
        "start": startTime.toIso8601String(),
        "end": endTime?.toIso8601String(),
        "entries": entries.map((e) => e.toJson()).toList(),
  };

  factory FeedingSession.fromJson(Map<String, dynamic> json) {
  // NEW FORMAT (correct)
  if (json["entries"] != null) {
    return FeedingSession(
      startTime: DateTime.parse(json["start"]),
      endTime: json["end"] != null ? DateTime.parse(json["end"]) : null,
      entries: (json["entries"] as List)
          .map((e) => FeedingEntry.fromJson(e))
          .toList(),
    );
  }

  // OLD FORMAT (backward compatibility)
    return FeedingSession(
      startTime: DateTime.parse(json["start"]),
      endTime: json["end"] != null ? DateTime.parse(json["end"]) : null,
      entries: [
        FeedingEntry(
          side: json["side"] ?? "left",
          duration: Duration(seconds: json["duration"] ?? 0),
        ),
      ],
    );
  }

}
