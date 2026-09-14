import 'baby_storage.dart';

abstract final class ActiveChildScope {
  static Future<String?> id() => BabyStorage().loadActiveProfileId();

  static Future<List<T>> filter<T>(
    List<T> records,
    String Function(T record) childId,
  ) async {
    final activeId = await id();
    if (activeId == null) return records;
    return records.where((record) => childId(record) == activeId).toList();
  }
}
