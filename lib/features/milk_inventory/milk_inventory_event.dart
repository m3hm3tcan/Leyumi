import 'milk_batch.dart';

enum MilkInventoryEventType {
  created,
  used,
  discarded,
  movedToFreezer,
  corrected,
}

class MilkInventoryEvent {
  const MilkInventoryEvent({
    required this.id,
    required this.batchId,
    required this.labelNumber,
    required this.type,
    required this.amountMl,
    required this.remainingAfterMl,
    required this.eventAt,
    required this.storageLocation,
    this.note,
  });

  final String id;
  final String batchId;
  final String labelNumber;
  final MilkInventoryEventType type;
  final int amountMl;
  final int remainingAfterMl;
  final DateTime eventAt;
  final MilkStorageLocation storageLocation;
  final String? note;

  MilkInventoryEvent copyWith({
    String? labelNumber,
    String? note,
  }) {
    return MilkInventoryEvent(
      id: id,
      batchId: batchId,
      labelNumber: labelNumber ?? this.labelNumber,
      type: type,
      amountMl: amountMl,
      remainingAfterMl: remainingAfterMl,
      eventAt: eventAt,
      storageLocation: storageLocation,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'batchId': batchId,
        'labelNumber': labelNumber,
        'type': type.name,
        'amountMl': amountMl,
        'remainingAfterMl': remainingAfterMl,
        'eventAt': eventAt.toIso8601String(),
        'storageLocation': storageLocation.name,
        'note': note,
      };

  factory MilkInventoryEvent.fromJson(Map<String, dynamic> json) {
    return MilkInventoryEvent(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      labelNumber: json['labelNumber'] as String,
      type: MilkInventoryEventType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => MilkInventoryEventType.corrected,
      ),
      amountMl: _readInt(json['amountMl']),
      remainingAfterMl: _readInt(json['remainingAfterMl']),
      eventAt: DateTime.parse(json['eventAt'] as String),
      storageLocation: MilkStorageLocation.values.firstWhere(
        (value) => value.name == json['storageLocation'],
        orElse: () => MilkStorageLocation.refrigerator,
      ),
      note: json['note'] as String?,
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
