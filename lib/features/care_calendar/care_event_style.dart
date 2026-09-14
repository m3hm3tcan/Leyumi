import 'package:flutter/material.dart';

import 'care_event.dart';

abstract final class CareEventStyle {
  static Color color(CareEventType type) => switch (type) {
    CareEventType.routine => const Color(0xff8B5CF6),
    CareEventType.plan => const Color(0xff3B82F6),
    CareEventType.reminder => const Color(0xffEC668B),
    CareEventType.care => const Color(0xff22A879),
    CareEventType.activity => const Color(0xffF59E0B),
    CareEventType.support => const Color(0xff06A6A6),
    CareEventType.custom => const Color(0xff64748B),
  };

  static IconData icon(CareEventType type) => switch (type) {
    CareEventType.routine => Icons.checklist_rounded,
    CareEventType.plan => Icons.calendar_month_rounded,
    CareEventType.reminder => Icons.notifications_none_rounded,
    CareEventType.care => Icons.child_care_rounded,
    CareEventType.activity => Icons.local_activity_outlined,
    CareEventType.support => Icons.volunteer_activism_outlined,
    CareEventType.custom => Icons.event_note,
  };
}
