import 'package:flutter/material.dart';

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

enum PoopAmount {
  small,
  medium,
  large,
}

enum PoopColor {
  mustardYellow,
  yellowGreen,
  brown,
  darkGreen,
  black,
  whiteGray,
}

class DiaperEntry {
  final DateTime timestamp;

  final DiaperType type;

  final PeeAmount? peeAmount;

  final PoopAmount? poopAmount;

  final PoopColor? poopColor;

  final String? note;

  DiaperEntry({
    required this.timestamp,
    required this.type,
    this.peeAmount,
    this.poopAmount,
    this.poopColor,
    this.note,
  });

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
    return DiaperEntry(
      timestamp: DateTime.parse(json["timestamp"]),

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
    );
  }

  // ---------------------------------------------------------
  // MODEL → JSON
  // ---------------------------------------------------------
  Map<String, dynamic> toJson() => {
        "timestamp": timestamp.toIso8601String(),
        "type": type.name,
        "peeAmount": peeAmount?.name,
        "poopAmount": poopAmount?.name,
        "poopColor": poopColor?.name,
        "note": note,
      };
}
