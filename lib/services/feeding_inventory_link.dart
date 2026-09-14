import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../core/database/app_database.dart';
import '../core/database/sqlite_records.dart';
import '../core/data/record_identity.dart';
import '../features/feeding/bottle_portion.dart';
import '../features/feeding/feeding_session.dart';
import '../features/milk_inventory/milk_batch.dart';
import '../features/milk_inventory/milk_inventory_event.dart';

/// Called inside the same transaction as the meal write or deletion.
abstract final class FeedingInventoryLink {
  static Map<String, int> _amounts(FeedingSession? meal) {
    final result = <String, int>{};
    for (final portion in meal?.bottles ?? <BottlePortion>[]) {
      if (portion.amountMl <= 0 ||
          (portion.batchId != null && portion.milk != BottleMilk.expressed)) {
        throw StateError('Invalid bottle portion');
      }
      final id = portion.batchId;
      if (id != null) result[id] = (result[id] ?? 0) + portion.amountMl;
    }
    return result;
  }

  static Future<void> reconcile(
    DatabaseExecutor db, {
    required FeedingSession? before,
    required FeedingSession? after,
    required bool inventoryAccess,
  }) async {
    final old = _amounts(before);
    final next = _amounts(after);
    final meal = after ?? before!;
    if (before != null && before.childId != meal.childId) {
      throw StateError('A meal cannot change child');
    }
    for (final id in {...old.keys, ...next.keys}) {
      final delta = (next[id] ?? 0) - (old[id] ?? 0);
      final timeChanged =
          before != null &&
          after != null &&
          before.startTime != after.startTime;
      if (delta == 0 && !timeChanged) continue;
      if (delta > 0 && !inventoryAccess) {
        throw StateError('Inventory requires Premium');
      }
      final rows = await db.query(
        AppDatabase.milkBatchesTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      // A deleted inventory batch must not prevent correcting meal history.
      if (rows.isEmpty && delta <= 0) continue;
      if (rows.isEmpty) throw StateError('Milk batch no longer exists');
      final batch = MilkBatch.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(rows.single['payload'] as String) as Map,
        ),
      );
      if (batch.childId != meal.childId) {
        throw StateError('Milk belongs to another child');
      }
      if ((next[id] ?? 0) > 0 && batch.expressedAt.isAfter(meal.startTime)) {
        throw StateError('Meal precedes milk expression');
      }
      if (delta == 0) continue;
      if (delta > 0 &&
          (!batch.isActive ||
              batch.isExpired ||
              batch.remainingAmountMl < delta ||
              batch.expressedAt.isAfter(meal.startTime))) {
        throw StateError('Milk batch is unavailable or insufficient');
      }
      final remaining = batch.remainingAmountMl - delta;
      final updated = batch.copyWith(
        remainingAmountMl: remaining,
        status: remaining == 0
            ? MilkBatchStatus.depleted
            : batch.status == MilkBatchStatus.discarded
            ? MilkBatchStatus.discarded
            : MilkBatchStatus.active,
      );
      await SqliteRecords.upsert(
        db,
        AppDatabase.milkBatchesTable,
        id: id,
        childId: batch.childId,
        sortTime: batch.createdAt,
        payload: updated.toJson(),
      );
      final event = MilkInventoryEvent(
        id: RecordIdentity.newId('feeding_stock'),
        childId: meal.childId,
        batchId: id,
        labelNumber: batch.labelNumber,
        type: delta > 0
            ? MilkInventoryEventType.used
            : MilkInventoryEventType.corrected,
        amountMl: delta.abs(),
        remainingAfterMl: remaining,
        eventAt: DateTime.now(),
        storageLocation: batch.storageLocation,
        note: 'Feeding: ${meal.id}',
      );
      await SqliteRecords.upsert(
        db,
        AppDatabase.milkEventsTable,
        id: event.id,
        childId: event.childId,
        sortTime: event.eventAt,
        payload: event.toJson(),
      );
    }
  }
}
