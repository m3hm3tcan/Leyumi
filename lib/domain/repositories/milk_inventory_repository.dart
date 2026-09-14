import '../../features/milk_inventory/milk_batch.dart';
import '../../features/milk_inventory/milk_inventory_event.dart';

abstract interface class MilkInventoryRepository {
  Future<List<MilkBatch>> loadBatches();
  Future<List<MilkInventoryEvent>> loadEvents();
  Future<void> saveAll(List<MilkBatch> batches);
  Future<void> saveEvents(List<MilkInventoryEvent> events);
  Future<void> addBatch(MilkBatch batch);
  Future<void> useMilk({
    required MilkBatch batch,
    required int amountMl,
    DateTime? usedAt,
  });
  Future<void> discardMilk({
    required MilkBatch batch,
    required int amountMl,
    String? note,
  });
  Future<void> moveToFreezer(MilkBatch batch);
  Future<void> updateBatch({
    required MilkBatch previous,
    required MilkBatch updated,
  });
  Future<void> deleteIncorrectBatch(String batchId);
}
