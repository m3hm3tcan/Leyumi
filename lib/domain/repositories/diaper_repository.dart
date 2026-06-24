import '../../features/diaper/diaper_entry.dart';

abstract interface class DiaperRepository {
  Future<void> addEntry(DiaperEntry entry);
  Future<List<DiaperEntry>> loadEntries();
  Future<void> saveAllEntries(List<DiaperEntry> entries);
}
