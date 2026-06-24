import '../core/data/record_identity.dart';

class BabyProfile {
  BabyProfile({
    String? id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.weight,
    required this.height,
    this.headCircumference,
    this.waistCircumference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? RecordIdentity.newId('child'),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String name;
  final String gender;
  final DateTime birthDate;
  final int weight;
  final int height;
  final int? headCircumference;
  final int? waistCircumference;
  final DateTime createdAt;
  final DateTime updatedAt;

  BabyProfile copyWith({
    String? name,
    String? gender,
    DateTime? birthDate,
    int? weight,
    int? height,
    int? headCircumference,
    int? waistCircumference,
    bool clearHeadCircumference = false,
    bool clearWaistCircumference = false,
  }) {
    return BabyProfile(
      id: id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      headCircumference: clearHeadCircumference
          ? null
          : headCircumference ?? this.headCircumference,
      waistCircumference: clearWaistCircumference
          ? null
          : waistCircumference ?? this.waistCircumference,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'id': id,
    'name': name,
    'gender': gender,
    'birthDate': birthDate.toIso8601String(),
    'weight': weight,
    'height': height,
    'headCircumference': headCircumference,
    'waistCircumference': waistCircumference,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    final birthDate = DateTime.parse(json['birthDate'] as String);
    return BabyProfile(
      id: json['id'] as String? ?? RecordIdentity.legacyId('child', birthDate),
      name: json['name'] as String,
      gender: json['gender'] as String,
      birthDate: birthDate,
      weight: _readInt(json['weight']),
      height: _readInt(json['height']),
      headCircumference: _readNullableInt(json['headCircumference']),
      waistCircumference: _readNullableInt(json['waistCircumference']),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? birthDate,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static int _readInt(dynamic value) =>
      value is num ? value.round() : int.parse(value.toString());

  static int? _readNullableInt(dynamic value) =>
      value == null ? null : _readInt(value);
}
