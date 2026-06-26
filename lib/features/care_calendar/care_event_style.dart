import 'package:flutter/material.dart';

import 'care_event.dart';

abstract final class CareEventStyle {
  static Color color(CareEventType type) => switch (type) {
    CareEventType.vaccine => const Color(0xff8B5CF6),
    CareEventType.doctor => const Color(0xff3B82F6),
    CareEventType.medicine => const Color(0xffEC668B),
    CareEventType.checkup => const Color(0xff22A879),
    CareEventType.laboratory => const Color(0xffF59E0B),
    CareEventType.therapy => const Color(0xff06A6A6),
    CareEventType.custom => const Color(0xff64748B),
  };

  static IconData icon(CareEventType type) => switch (type) {
    CareEventType.vaccine => Icons.local_hospital,
    CareEventType.doctor => Icons.healing,
    CareEventType.medicine => Icons.local_pharmacy,
    CareEventType.checkup => Icons.favorite,
    CareEventType.laboratory => Icons.science,
    CareEventType.therapy => Icons.accessibility_new,
    CareEventType.custom => Icons.event_note,
  };
}
