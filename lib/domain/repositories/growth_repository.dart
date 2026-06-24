import '../../models/growth_entry.dart';

abstract interface class GrowthRepository {
  Future<void> addEntry(GrowthEntry entry);
  Future<List<GrowthEntry>> loadEntries();
  Future<void> saveAllEntries(List<GrowthEntry> entries);
  Future<void> deleteEntry(GrowthEntry entry);
}
