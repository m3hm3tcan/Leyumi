enum DiaperType {
  pee,
  poop,
  both,
}

enum PeeAmount {
  small,
  medium,
  large,
}

enum PoopColor {
  yellow,
  brown,
  green,
  black,
}

class DiaperEntry {
  final DateTime timestamp;

  final DiaperType type;

  final PeeAmount? peeAmount;

  final PoopColor? poopColor;

  final String? note;

  DiaperEntry({
    required this.timestamp,
    required this.type,
    this.peeAmount,
    this.poopColor,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        "timestamp": timestamp.toIso8601String(),
        "type": type.name,
        "peeAmount": peeAmount?.name,
        "poopColor": poopColor?.name,
        "note": note,
      };

  factory DiaperEntry.fromJson(Map<String, dynamic> json) {
    return DiaperEntry(
      timestamp: DateTime.parse(json["timestamp"]),
      type: DiaperType.values.firstWhere(
        (e) => e.name == json["type"],
      ),
      peeAmount: json["peeAmount"] != null
          ? PeeAmount.values.firstWhere(
              (e) => e.name == json["peeAmount"],
            )
          : null,
      poopColor: json["poopColor"] != null
          ? PoopColor.values.firstWhere(
              (e) => e.name == json["poopColor"],
            )
          : null,
      note: json["note"],
    );
  }
}