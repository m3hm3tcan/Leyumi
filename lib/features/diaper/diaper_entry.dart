import '../../core/data/record_identity.dart';

enum DiaperType { pee, poop, both }

enum PeeAmount { small, medium, large }

enum PoopAmount { small, medium, large }

enum PoopColor {
  mustardYellow,
  yellowGreen,
  brown,
  darkGreen,
  black,
  whiteGray,
}

class DiaperEntry {
  final String id;
  final String childId;
  final DateTime timestamp;

  final DiaperType type;

  final PeeAmount? peeAmount;

  final PoopAmount? poopAmount;

  final PoopColor? poopColor;

  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaperEntry({
    String? id,
    this.childId = RecordIdentity.legacyChildId,
    required this.timestamp,
    required this.type,
    this.peeAmount,
    this.poopAmount,
    this.poopColor,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? RecordIdentity.newId('diaper'),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // ---------------------------------------------------------
  // MIGRATION: Eski poopColor değerlerini yeni enum'a çevirir
  // ---------------------------------------------------------
  static PoopColor _mapOldPoopColor(String? value) {
    switch (value) {
      case "yellow":
      case "mustardYellow":
        return PoopColor.mustardYellow;

      case "green":
      case "yellowGreen":
        return PoopColor.yellowGreen;

      case "brown":
        return PoopColor.brown;

      case "darkGreen":
        return PoopColor.darkGreen;

      case "black":
        return PoopColor.black;

      case "whiteGray":
        return PoopColor.whiteGray;

      // Eski kayıtlarda olmayan ama null gelebilecek durumlar için
      default:
        return PoopColor.mustardYellow;
    }
  }

  // ---------------------------------------------------------
  // JSON → MODEL
  // ---------------------------------------------------------
  factory DiaperEntry.fromJson(Map<String, dynamic> json) {
    final timestamp = DateTime.parse(json["timestamp"]);
    return DiaperEntry(
      id: json['id'] as String? ?? RecordIdentity.legacyId('diaper', timestamp),
      childId: json['childId'] as String? ?? RecordIdentity.legacyChildId,
      timestamp: timestamp,

      type: DiaperType.values.firstWhere(
        (e) => e.name == json["type"],
        orElse: () => DiaperType.pee,
      ),

      peeAmount: json["peeAmount"] != null
          ? PeeAmount.values.firstWhere(
              (e) => e.name == json["peeAmount"],
              orElse: () => PeeAmount.medium,
            )
          : null,

      // Eski kayıtlarda bu alan bulunmaz; null kalması geriye dönük uyumludur.
      poopAmount: json["poopAmount"] != null
          ? PoopAmount.values.firstWhere(
              (e) => e.name == json["poopAmount"],
              orElse: () => PoopAmount.medium,
            )
          : null,

      // MIGRATION: Yeni enum yoksa eski değerleri dönüştür
      poopColor: json["poopColor"] != null
          ? _mapOldPoopColor(json["poopColor"])
          : null,

      note: json["note"],
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? timestamp,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? timestamp,
    );
  }

  // ---------------------------------------------------------
  // MODEL → JSON
  // ---------------------------------------------------------
  Map<String, dynamic> toJson() => {
    "schemaVersion": 2,
    "id": id,
    "childId": childId,
    "timestamp": timestamp.toIso8601String(),
    "type": type.name,
    "peeAmount": peeAmount?.name,
    "poopAmount": poopAmount?.name,
    "poopColor": poopColor?.name,
    "note": note,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
