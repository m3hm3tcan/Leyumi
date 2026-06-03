class FeedingEntry {
  final String side; // "left" or "right"
  final Duration duration;

  FeedingEntry({
    required this.side,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        "side": side,
        "duration": duration.inSeconds,
      };

  factory FeedingEntry.fromJson(Map<String, dynamic> json) {
    return FeedingEntry(
      side: json["side"],
      duration: Duration(seconds: json["duration"]),
    );
  }
}
