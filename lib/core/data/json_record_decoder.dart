import 'dart:convert';

import '../logging/app_logger.dart';

abstract final class JsonRecordDecoder {
  static List<T> decodeStringList<T>({
    required Iterable<String> values,
    required T Function(Map<String, dynamic> json) fromJson,
    required String source,
  }) {
    final records = <T>[];
    for (final value in values) {
      try {
        final decoded = jsonDecode(value);
        records.add(fromJson(Map<String, dynamic>.from(decoded as Map)));
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed $source record was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return records;
  }

  static List<T> decodeArray<T>({
    required String value,
    required T Function(Map<String, dynamic> json) fromJson,
    required String source,
  }) {
    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      final records = <T>[];
      for (final item in decoded) {
        try {
          records.add(fromJson(Map<String, dynamic>.from(item as Map)));
        } catch (error, stackTrace) {
          AppLogger.warning(
            'A malformed $source record was skipped.',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
      return records;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'The $source collection could not be read.',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}
