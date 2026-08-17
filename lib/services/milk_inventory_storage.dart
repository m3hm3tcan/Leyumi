import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/sqlite_records.dart';
import '../core/logging/app_logger.dart';
import '../domain/repositories/milk_inventory_repository.dart';
import '../features/milk_inventory/milk_batch.dart';
import '../features/milk_inventory/milk_inventory_event.dart';
import 'active_child_scope.dart';

class MilkInventoryStorage implements MilkInventoryRepository {
  @override
  Future<List<MilkBatch>> loadBatches() async {
    final db = await AppDatabase.instance;
    return _loadBatches(db, childId: await ActiveChildScope.id());
  }

  Future<List<MilkBatch>> _loadBatches(
    DatabaseExecutor db, {
    String? childId,
  }) async {
    final payloads = await SqliteRecords.readPayloads(
      db,
      AppDatabase.milkBatchesTable,
      childId: childId,
    );
    final batches = <MilkBatch>[];
    for (final payload in payloads) {
      try {
        batches.add(MilkBatch.fromJson(payload));
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed milk batch was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return batches;
  }

  @override
  Future<List<MilkInventoryEvent>> loadEvents() async {
    final db = await AppDatabase.instance;
    return _loadEvents(db, childId: await ActiveChildScope.id());
  }

  Future<List<MilkInventoryEvent>> _loadEvents(
    DatabaseExecutor db, {
    String? childId,
  }) async {
    final payloads = await SqliteRecords.readPayloads(
      db,
      AppDatabase.milkEventsTable,
      childId: childId,
    );
    final events = <MilkInventoryEvent>[];
    for (final payload in payloads) {
      try {
        events.add(MilkInventoryEvent.fromJson(payload));
      } catch (error, stackTrace) {
        AppLogger.warning(
          'A malformed milk inventory event was skipped.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return events;
  }

  @override
  Future<void> saveAll(List<MilkBatch> batches) async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    await db.transaction(
      (txn) => _replaceBatches(txn, batches, childId: childId),
    );
  }

  @override
  Future<void> saveEvents(List<MilkInventoryEvent> events) async {
    final db = await AppDatabase.instance;
    final childId = await ActiveChildScope.id();
    await db.transaction(
      (txn) => _replaceEvents(txn, events, childId: childId),
    );
  }

  @override
  Future<void> addBatch(MilkBatch batch) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      await _upsertBatch(txn, batch);
      await _upsertEvent(
        txn,
        MilkInventoryEvent(
          id: _newId(),
          childId: batch.childId,
          batchId: batch.id,
          labelNumber: batch.labelNumber,
          type: MilkInventoryEventType.created,
          amountMl: batch.initialAmountMl,
          remainingAfterMl: batch.remainingAmountMl,
          eventAt: batch.createdAt,
          storageLocation: batch.storageLocation,
        ),
      );
    });
  }

  @override
  Future<void> useMilk({
    required MilkBatch batch,
    required int amountMl,
    DateTime? usedAt,
  }) async {
    await _changeAmount(
      batch: batch,
      amountMl: amountMl,
      eventAt: usedAt ?? DateTime.now(),
      eventType: MilkInventoryEventType.used,
      depletedStatus: MilkBatchStatus.depleted,
    );
  }

  @override
  Future<void> discardMilk({
    required MilkBatch batch,
    required int amountMl,
    String? note,
  }) async {
    await _changeAmount(
      batch: batch,
      amountMl: amountMl,
      eventAt: DateTime.now(),
      eventType: MilkInventoryEventType.discarded,
      depletedStatus: MilkBatchStatus.discarded,
      note: note,
    );
  }

  Future<void> _changeAmount({
    required MilkBatch batch,
    required int amountMl,
    required DateTime eventAt,
    required MilkInventoryEventType eventType,
    required MilkBatchStatus depletedStatus,
    String? note,
  }) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      final current = await _findBatch(txn, batch.id);
      if (current == null || current.remainingAmountMl <= 0) return;
      final safeAmount = amountMl.clamp(1, current.remainingAmountMl).toInt();
      final remaining = current.remainingAmountMl - safeAmount;
      final updated = current.copyWith(
        remainingAmountMl: remaining,
        status: remaining == 0 ? depletedStatus : MilkBatchStatus.active,
      );
      await _upsertBatch(txn, updated);
      await _upsertEvent(
        txn,
        MilkInventoryEvent(
          id: _newId(),
          childId: current.childId,
          batchId: current.id,
          labelNumber: current.labelNumber,
          type: eventType,
          amountMl: safeAmount,
          remainingAfterMl: remaining,
          eventAt: eventAt,
          storageLocation: current.storageLocation,
          note: note,
        ),
      );
    });
  }

  @override
  Future<void> moveToFreezer(MilkBatch batch) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      final current = await _findBatch(txn, batch.id);
      if (current == null) return;
      final movedAt = DateTime.now();
      final updated = current.copyWith(
        storageLocation: MilkStorageLocation.freezer,
        frozenAt: movedAt,
      );
      await _upsertBatch(txn, updated);
      await _upsertEvent(
        txn,
        MilkInventoryEvent(
          id: _newId(),
          childId: current.childId,
          batchId: current.id,
          labelNumber: current.labelNumber,
          type: MilkInventoryEventType.movedToFreezer,
          amountMl: 0,
          remainingAfterMl: current.remainingAmountMl,
          eventAt: movedAt,
          storageLocation: MilkStorageLocation.freezer,
        ),
      );
    });
  }

  @override
  Future<void> updateBatch({
    required MilkBatch previous,
    required MilkBatch updated,
  }) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      final current = await _findBatch(txn, previous.id);
      if (current == null) return;
      await _upsertBatch(txn, updated);
      if (updated.labelNumber != current.labelNumber) {
        final linkedEvents = await _loadEventsForBatch(txn, updated.id);
        for (final event in linkedEvents) {
          await _upsertEvent(
            txn,
            event.copyWith(labelNumber: updated.labelNumber),
          );
        }
      }
      await _upsertEvent(
        txn,
        MilkInventoryEvent(
          id: _newId(),
          childId: updated.childId,
          batchId: updated.id,
          labelNumber: updated.labelNumber,
          type: MilkInventoryEventType.corrected,
          amountMl: updated.remainingAmountMl - current.remainingAmountMl,
          remainingAfterMl: updated.remainingAmountMl,
          eventAt: DateTime.now(),
          storageLocation: updated.storageLocation,
        ),
      );
    });
  }

  @override
  Future<void> deleteIncorrectBatch(String batchId) async {
    final db = await AppDatabase.instance;
    await db.transaction((txn) async {
      final linkedEvents = await _loadEventsForBatch(txn, batchId);
      for (final event in linkedEvents) {
        await txn.delete(
          AppDatabase.milkEventsTable,
          where: 'id = ?',
          whereArgs: [event.id],
        );
      }
      await txn.delete(
        AppDatabase.milkBatchesTable,
        where: 'id = ?',
        whereArgs: [batchId],
      );
    });
  }

  Future<MilkBatch?> _findBatch(DatabaseExecutor db, String id) async {
    final rows = await db.query(
      AppDatabase.milkBatchesTable,
      columns: const ['payload'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MilkBatch.fromJson(
      Map<String, dynamic>.from(
        jsonDecode(rows.first['payload']! as String) as Map,
      ),
    );
  }

  Future<List<MilkInventoryEvent>> _loadEventsForBatch(
    DatabaseExecutor db,
    String batchId,
  ) async {
    final events = await _loadEvents(db);
    return events.where((event) => event.batchId == batchId).toList();
  }

  Future<void> _replaceBatches(
    DatabaseExecutor db,
    List<MilkBatch> batches, {
    required String? childId,
  }) async {
    await db.delete(
      AppDatabase.milkBatchesTable,
      where: childId == null ? null : 'child_id = ?',
      whereArgs: childId == null ? null : [childId],
    );
    for (final batch in batches) {
      await _upsertBatch(db, batch);
    }
  }

  Future<void> _replaceEvents(
    DatabaseExecutor db,
    List<MilkInventoryEvent> events, {
    required String? childId,
  }) async {
    await db.delete(
      AppDatabase.milkEventsTable,
      where: childId == null ? null : 'child_id = ?',
      whereArgs: childId == null ? null : [childId],
    );
    for (final event in events) {
      await _upsertEvent(db, event);
    }
  }

  Future<void> _upsertBatch(DatabaseExecutor db, MilkBatch batch) {
    return SqliteRecords.upsert(
      db,
      AppDatabase.milkBatchesTable,
      id: batch.id,
      childId: batch.childId,
      sortTime: batch.createdAt,
      payload: batch.toJson(),
    );
  }

  Future<void> _upsertEvent(DatabaseExecutor db, MilkInventoryEvent event) {
    return SqliteRecords.upsert(
      db,
      AppDatabase.milkEventsTable,
      id: event.id,
      childId: event.childId,
      sortTime: event.eventAt,
      payload: event.toJson(),
    );
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
