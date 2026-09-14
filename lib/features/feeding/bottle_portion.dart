import '../../core/data/record_identity.dart';

enum BottleMilk { formula, expressed }

/// A measured part of a meal. Breastfeeding remains represented by side entries.
class BottlePortion {
  BottlePortion({
    String? id,
    required this.milk,
    required this.amountMl,
    this.batchId,
  }) : id = id ?? RecordIdentity.newId('bottle');

  final String id;
  final BottleMilk milk;
  final int amountMl;
  final String? batchId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'milk': milk.name,
    'amountMl': amountMl,
    'batchId': batchId,
  };

  factory BottlePortion.fromJson(Map<String, dynamic> json) => BottlePortion(
    id: json['id'] as String,
    milk: BottleMilk.values.byName(json['milk'] as String),
    amountMl: (json['amountMl'] as num).toInt(),
    batchId: json['batchId'] as String?,
  );
}
