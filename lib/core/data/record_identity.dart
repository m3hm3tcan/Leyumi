abstract final class RecordIdentity {
  static const legacyChildId = 'legacy-default-child';

  static String newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  static String legacyId(String prefix, DateTime timestamp) =>
      '$prefix-legacy-${timestamp.microsecondsSinceEpoch}';
}
