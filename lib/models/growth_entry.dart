import '../core/data/record_identity.dart';

class GrowthEntry {
  GrowthEntry({
    String? id,
    this.childId = RecordIdentity.legacyChildId,
    required this.date,
    required this.weight,
    required this.height,
    this.headCircumference,
    this.waistCircumference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? RecordIdentity.newId('growth'),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String childId;
  final DateTime date;
  final int weight;
  final int height;
  final int? headCircumference;
  final int? waistCircumference;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'id': id,
    'childId': childId,
    'date': date.toIso8601String(),
    'weight': weight,
    'height': height,
    'headCircumference': headCircumference,
    'waistCircumference': waistCircumference,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory GrowthEntry.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    return GrowthEntry(
      id: json['id'] as String? ?? RecordIdentity.legacyId('growth', date),
      childId: json['childId'] as String? ?? RecordIdentity.legacyChildId,
      date: date,
      weight: _readInt(json['weight']),
      height: _readInt(json['height']),
      headCircumference: _readNullableInt(json['headCircumference']),
      waistCircumference: _readNullableInt(json['waistCircumference']),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? date,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? date,
    );
  }

  static int _readInt(dynamic value) =>
      value is num ? value.round() : int.parse(value.toString());

  static int? _readNullableInt(dynamic value) =>
      value == null ? null : _readInt(value);
}
