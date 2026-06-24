import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/milk_inventory/milk_batch.dart';
import '../features/milk_inventory/milk_inventory_event.dart';
import '../domain/repositories/milk_inventory_repository.dart';
import '../core/data/json_record_decoder.dart';
import 'active_child_scope.dart';

class MilkInventoryStorage implements MilkInventoryRepository {
  static const key = 'milk_inventory_batches';
  static const eventKey = 'milk_inventory_events';
  static const migrationKey = 'milk_inventory_events_migrated_v1';

  Future<List<MilkBatch>> loadBatches() async {
    final batches = await _loadAllBatches();
    return ActiveChildScope.filter(batches, (batch) => batch.childId);
  }

  Future<List<MilkBatch>> _loadAllBatches() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) return [];

    return JsonRecordDecoder.decodeArray(
      value: raw,
      fromJson: MilkBatch.fromJson,
      source: 'milk inventory',
    );
  }

  Future<List<MilkInventoryEvent>> loadEvents() async {
    await _migrateExistingBatchesToEvents();
    final events = await _loadAllEvents();
    return ActiveChildScope.filter(events, (event) => event.childId);
  }

  Future<List<MilkInventoryEvent>> _loadAllEvents() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(eventKey);
    if (raw == null || raw.isEmpty) return [];

    return JsonRecordDecoder.decodeArray(
      value: raw,
      fromJson: MilkInventoryEvent.fromJson,
      source: 'milk inventory event',
    );
  }

  Future<void> saveAll(List<MilkBatch> batches) async {
    final activeId = await ActiveChildScope.id();
    final allBatches = await _loadAllBatches();
    final merged = activeId == null
        ? batches
        : [
            ...allBatches.where((batch) => batch.childId != activeId),
            ...batches,
          ];
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode(merged.map((batch) => batch.toJson()).toList()),
    );
  }

  Future<void> saveEvents(List<MilkInventoryEvent> events) async {
    final activeId = await ActiveChildScope.id();
    final allEvents = await _loadAllEvents();
    final merged = activeId == null
        ? events
        : [...allEvents.where((event) => event.childId != activeId), ...events];
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      eventKey,
      jsonEncode(merged.map((event) => event.toJson()).toList()),
    );
  }

  Future<void> addBatch(MilkBatch batch) async {
    final batches = await _loadAllBatches();
    final events = await _loadAllEvents();

    batches.add(batch);
    events.add(
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

    await _saveState(batches: batches, events: events);
  }

  Future<void> useMilk({
    required MilkBatch batch,
    required int amountMl,
    DateTime? usedAt,
  }) async {
    final batches = await _loadAllBatches();
    final events = await _loadAllEvents();
    final index = batches.indexWhere((item) => item.id == batch.id);
    if (index < 0) return;

    final safeAmount = amountMl.clamp(1, batch.remainingAmountMl).toInt();
    final remaining = batch.remainingAmountMl - safeAmount;
    final updated = batch.copyWith(
      remainingAmountMl: remaining,
      status: remaining == 0
          ? MilkBatchStatus.depleted
          : MilkBatchStatus.active,
    );

    batches[index] = updated;
    events.add(
      MilkInventoryEvent(
        id: _newId(),
        childId: batch.childId,
        batchId: batch.id,
        labelNumber: batch.labelNumber,
        type: MilkInventoryEventType.used,
        amountMl: safeAmount,
        remainingAfterMl: remaining,
        eventAt: usedAt ?? DateTime.now(),
        storageLocation: batch.storageLocation,
      ),
    );

    await _saveState(batches: batches, events: events);
  }

  Future<void> discardMilk({
    required MilkBatch batch,
    required int amountMl,
    String? note,
  }) async {
    final batches = await _loadAllBatches();
    final events = await _loadAllEvents();
    final index = batches.indexWhere((item) => item.id == batch.id);
    if (index < 0) return;

    final safeAmount = amountMl.clamp(1, batch.remainingAmountMl).toInt();
    final remaining = batch.remainingAmountMl - safeAmount;
    batches[index] = batch.copyWith(
      remainingAmountMl: remaining,
      status: remaining == 0
          ? MilkBatchStatus.discarded
          : MilkBatchStatus.active,
    );
    events.add(
      MilkInventoryEvent(
        id: _newId(),
        childId: batch.childId,
        batchId: batch.id,
        labelNumber: batch.labelNumber,
        type: MilkInventoryEventType.discarded,
        amountMl: safeAmount,
        remainingAfterMl: remaining,
        eventAt: DateTime.now(),
        storageLocation: batch.storageLocation,
        note: note,
      ),
    );

    await _saveState(batches: batches, events: events);
  }

  Future<void> moveToFreezer(MilkBatch batch) async {
    final batches = await _loadAllBatches();
    final events = await _loadAllEvents();
    final index = batches.indexWhere((item) => item.id == batch.id);
    if (index < 0) return;

    final movedAt = DateTime.now();
    batches[index] = batch.copyWith(
      storageLocation: MilkStorageLocation.freezer,
      frozenAt: movedAt,
    );
    events.add(
      MilkInventoryEvent(
        id: _newId(),
        childId: batch.childId,
        batchId: batch.id,
        labelNumber: batch.labelNumber,
        type: MilkInventoryEventType.movedToFreezer,
        amountMl: 0,
        remainingAfterMl: batch.remainingAmountMl,
        eventAt: movedAt,
        storageLocation: MilkStorageLocation.freezer,
      ),
    );

    await _saveState(batches: batches, events: events);
  }

  Future<void> updateBatch({
    required MilkBatch previous,
    required MilkBatch updated,
  }) async {
    final batches = await _loadAllBatches();
    final events = await _loadAllEvents();
    final index = batches.indexWhere((item) => item.id == previous.id);
    if (index < 0) return;

    batches[index] = updated;
    if (updated.labelNumber != previous.labelNumber) {
      for (var eventIndex = 0; eventIndex < events.length; eventIndex++) {
        final event = events[eventIndex];
        if (event.batchId == updated.id) {
          events[eventIndex] = event.copyWith(labelNumber: updated.labelNumber);
        }
      }
    }
    events.add(
      MilkInventoryEvent(
        id: _newId(),
        childId: updated.childId,
        batchId: updated.id,
        labelNumber: updated.labelNumber,
        type: MilkInventoryEventType.corrected,
        amountMl: updated.remainingAmountMl - previous.remainingAmountMl,
        remainingAfterMl: updated.remainingAmountMl,
        eventAt: DateTime.now(),
        storageLocation: updated.storageLocation,
      ),
    );

    await _saveState(batches: batches, events: events);
  }

  /// Removes an incorrectly entered batch and all events linked to it.
  Future<void> deleteIncorrectBatch(String batchId) async {
    final batches = await _loadAllBatches();
    final events = await _loadAllEvents();
    batches.removeWhere((batch) => batch.id == batchId);
    events.removeWhere((event) => event.batchId == batchId);
    await _saveState(batches: batches, events: events);
  }

  Future<void> _saveState({
    required List<MilkBatch> batches,
    required List<MilkInventoryEvent> events,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode(batches.map((batch) => batch.toJson()).toList()),
    );
    await preferences.setString(
      eventKey,
      jsonEncode(events.map((event) => event.toJson()).toList()),
    );
  }

  Future<void> _migrateExistingBatchesToEvents() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(migrationKey) ?? false) return;

    final batches = await _loadAllBatches();
    final rawEvents = preferences.getString(eventKey);
    final hasEvents = rawEvents != null && rawEvents.isNotEmpty;

    if (!hasEvents && batches.isNotEmpty) {
      final events = batches.map((batch) {
        return MilkInventoryEvent(
          id: 'migrated-${batch.id}',
          childId: batch.childId,
          batchId: batch.id,
          labelNumber: batch.labelNumber,
          type: MilkInventoryEventType.created,
          amountMl: batch.initialAmountMl,
          remainingAfterMl: batch.remainingAmountMl,
          eventAt: batch.createdAt,
          storageLocation: batch.storageLocation,
          note: 'migrated',
        );
      }).toList();
      await saveEvents(events);
    }

    if (batches.isNotEmpty) {
      await preferences.setString(
        key,
        jsonEncode(batches.map((batch) => batch.toJson()).toList()),
      );
    }
    await preferences.setBool(migrationKey, true);
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
