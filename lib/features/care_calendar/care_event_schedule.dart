import 'care_event.dart';

abstract final class CareEventSchedule {
  static bool occursOn(CareEvent event, DateTime day) {
    final target = dateOnly(day);
    final start = dateOnly(event.scheduledAt);
    if (target.isBefore(start)) return false;

    return switch (event.recurrence) {
      CareEventRecurrence.none => target.isAtSameMomentAs(start),
      CareEventRecurrence.daily => true,
      CareEventRecurrence.weekly =>
        target.difference(start).inDays.remainder(7) == 0,
      CareEventRecurrence.monthly =>
        target.day == start.day ||
            (target.day == _lastDay(target) && start.day > _lastDay(target)),
    };
  }

  static DateTime? nextOccurrence(CareEvent event, DateTime from) {
    if (event.status != CareEventStatus.scheduled) return null;
    final start = event.scheduledAt;
    if (event.recurrence == CareEventRecurrence.none) {
      return start.isBefore(from) ? null : start;
    }

    var day = dateOnly(from);
    if (day.isBefore(dateOnly(start))) day = dateOnly(start);
    for (var index = 0; index < 370; index++) {
      if (occursOn(event, day)) {
        final occurrence = DateTime(
          day.year,
          day.month,
          day.day,
          start.hour,
          start.minute,
        );
        if (!occurrence.isBefore(from)) return occurrence;
      }
      day = day.add(const Duration(days: 1));
    }
    return null;
  }

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int _lastDay(DateTime value) =>
      DateTime(value.year, value.month + 1, 0).day;
}
