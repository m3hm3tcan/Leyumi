enum FeedingSide { left, right }

class FeedingEntry {
  final FeedingSide side;
  final Duration duration;

  FeedingEntry({
    required this.side,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        "side": side.name,
        "duration": duration.inSeconds,
      };

  factory FeedingEntry.fromJson(Map<String, dynamic> json) {
    return FeedingEntry(
      side: (json["side"] == "left")
          ? FeedingSide.left
          : FeedingSide.right,
      duration: Duration(seconds: json["duration"]),
    );
  }
}