import 'package:flutter/foundation.dart';

import '../../domain/repositories/milk_inventory_repository.dart';
import '../../services/milk_inventory_storage.dart';
import 'milk_batch.dart';

class MilkInventoryController extends ChangeNotifier {
  MilkInventoryController({MilkInventoryRepository? repository})
    : _repository = repository ?? MilkInventoryStorage();

  final MilkInventoryRepository _repository;
  List<MilkBatch> _batches = [];
  MilkStorageLocation? _filter;
  bool _loading = true;

  List<MilkBatch> get batches => List.unmodifiable(_batches);
  MilkStorageLocation? get filter => _filter;
  bool get loading => _loading;

  List<MilkBatch> get visibleBatches {
    return _batches
        .where(
          (batch) =>
              batch.isActive &&
              (_filter == null || batch.storageLocation == _filter),
        )
        .toList();
  }

  int get totalMl => _batches
      .where((batch) => batch.isActive)
      .fold(0, (total, batch) => total + batch.remainingAmountMl);

  bool get hasSourceStats => _batches.any(
    (batch) => batch.isActive && batch.sourceSide != MilkSourceSide.unspecified,
  );

  int locationTotal(MilkStorageLocation location) {
    return _batches
        .where((batch) => batch.isActive && batch.storageLocation == location)
        .fold(0, (total, batch) => total + batch.remainingAmountMl);
  }

  int sourceTotal(MilkSourceSide source) {
    return _batches
        .where((batch) => batch.isActive && batch.sourceSide == source)
        .fold(0, (total, batch) => total + batch.remainingAmountMl);
  }

  String nextLabel() {
    var highest = 0;
    final pattern = RegExp(r'(\d+)$');
    for (final batch in _batches) {
      final match = pattern.firstMatch(batch.labelNumber);
      final value = match == null ? null : int.tryParse(match.group(1)!);
      if (value != null && value > highest) highest = value;
    }
    return 'MILK-${(highest + 1).toString().padLeft(3, '0')}';
  }

  void setFilter(MilkStorageLocation? value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final batches = await _repository.loadBatches();
    batches.sort((a, b) => a.bestBefore.compareTo(b.bestBefore));
    _batches = batches;
    _loading = false;
    notifyListeners();
  }

  Future<void> add(MilkBatch batch) async {
    await _repository.addBatch(batch);
    await load();
  }

  Future<void> deleteIncorrect(MilkBatch batch) async {
    await _repository.deleteIncorrectBatch(batch.id);
    await load();
  }

  Future<void> use(MilkBatch batch, int amountMl) async {
    await _repository.useMilk(batch: batch, amountMl: amountMl);
    await load();
  }

  Future<void> discard(MilkBatch batch, int amountMl) async {
    await _repository.discardMilk(batch: batch, amountMl: amountMl);
    await load();
  }

  Future<void> update(MilkBatch previous, MilkBatch updated) async {
    await _repository.updateBatch(previous: previous, updated: updated);
    await load();
  }

  Future<void> moveToFreezer(MilkBatch batch) async {
    await _repository.moveToFreezer(batch);
    await load();
  }
}
