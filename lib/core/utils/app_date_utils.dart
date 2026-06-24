import 'package:flutter/material.dart';

abstract final class AppDateUtils {
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  static bool isToday(DateTime value) => isSameDay(value, DateTime.now());

  static DateTime startOfRange(int days, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    return today.subtract(Duration(days: days - 1));
  }
}

abstract final class AppDateFormatter {
  static String sectionDate(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatMediumDate(value);

  static String shortDate(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatShortDate(value);

  static String time(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(
        context,
      ).formatTimeOfDay(TimeOfDay.fromDateTime(value));
}
