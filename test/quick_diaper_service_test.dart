import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/domain/repositories/diaper_repository.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/home/quick_diaper_service.dart';

void main() {
  test(
    'saves only the selected type without inventing optional details',
    () async {
      final repository = _FakeDiaperRepository();
      final now = DateTime(2026, 8, 23, 22);
      final service = QuickDiaperService(
        repository: repository,
        clock: () => now,
      );

      final saved = await service.save(
        childId: 'child-1',
        type: DiaperType.poop,
      );

      expect(saved, isNotNull);
      expect(saved!.type, DiaperType.poop);
      expect(saved.timestamp, now);
      expect(saved.peeAmount, isNull);
      expect(saved.poopAmount, isNull);
      expect(saved.poopColor, isNull);
      expect(repository.entries, hasLength(1));
    },
  );

  test(
    'ignores a rapid duplicate and allows saving again after undo',
    () async {
      final repository = _FakeDiaperRepository();
      final now = DateTime(2026, 8, 23, 22);
      final service = QuickDiaperService(
        repository: repository,
        clock: () => now,
      );

      final first = await service.save(
        childId: 'child-1',
        type: DiaperType.pee,
      );
      final duplicate = await service.save(
        childId: 'child-1',
        type: DiaperType.pee,
      );

      expect(first, isNotNull);
      expect(duplicate, isNull);
      expect(repository.entries, hasLength(1));

      await service.undo(first!);
      final afterUndo = await service.save(
        childId: 'child-1',
        type: DiaperType.pee,
      );

      expect(afterUndo, isNotNull);
      expect(repository.entries, hasLength(1));
    },
  );
}

class _FakeDiaperRepository implements DiaperRepository {
  final entries = <DiaperEntry>[];

  @override
  Future<void> addEntry(DiaperEntry entry) async => entries.add(entry);

  @override
  Future<void> deleteEntry({
    required String id,
    required String childId,
  }) async => entries.removeWhere(
    (entry) => entry.id == id && entry.childId == childId,
  );

  @override
  Future<List<DiaperEntry>> loadEntries() async => List.of(entries);

  @override
  Future<void> saveAllEntries(List<DiaperEntry> entries) async {
    this.entries
      ..clear()
      ..addAll(entries);
  }
}
