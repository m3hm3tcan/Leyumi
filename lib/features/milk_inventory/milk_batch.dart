enum MilkStorageLocation { refrigerator, freezer }

enum MilkSourceSide { left, right, mixed, unspecified }

enum MilkBatchStatus { active, depleted, discarded }

class MilkBatch {
  const MilkBatch({
    required this.id,
    required this.labelNumber,
    required this.initialAmountMl,
    required this.remainingAmountMl,
    required this.expressedAt,
    required this.storageLocation,
    required this.sourceSide,
    required this.createdAt,
    this.status = MilkBatchStatus.active,
    this.frozenAt,
  });

  final String id;
  final String labelNumber;
  final int initialAmountMl;
  final int remainingAmountMl;
  final DateTime expressedAt;
  final MilkStorageLocation storageLocation;
  final MilkSourceSide sourceSide;
  final DateTime createdAt;
  final MilkBatchStatus status;
  final DateTime? frozenAt;

  /// Kept as a compatibility alias for screens or older code that still reads
  /// amountMl. It now represents the current remaining amount.
  int get amountMl => remainingAmountMl;

  DateTime get bestBefore {
    if (storageLocation == MilkStorageLocation.refrigerator) {
      return expressedAt.add(const Duration(days: 4));
    }
    return (frozenAt ?? expressedAt).add(const Duration(days: 180));
  }

  bool get isExpired => DateTime.now().isAfter(bestBefore);
  bool get isActive =>
      status == MilkBatchStatus.active && remainingAmountMl > 0;

  double get fillRatio =>
      (remainingAmountMl / 500).clamp(0, 1).toDouble();

  MilkBatch copyWith({
    String? id,
    String? labelNumber,
    int? initialAmountMl,
    int? remainingAmountMl,
    DateTime? expressedAt,
    MilkStorageLocation? storageLocation,
    MilkSourceSide? sourceSide,
    DateTime? createdAt,
    MilkBatchStatus? status,
    DateTime? frozenAt,
    bool clearFrozenAt = false,
  }) {
    return MilkBatch(
      id: id ?? this.id,
      labelNumber: labelNumber ?? this.labelNumber,
      initialAmountMl: initialAmountMl ?? this.initialAmountMl,
      remainingAmountMl: remainingAmountMl ?? this.remainingAmountMl,
      expressedAt: expressedAt ?? this.expressedAt,
      storageLocation: storageLocation ?? this.storageLocation,
      sourceSide: sourceSide ?? this.sourceSide,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      frozenAt: clearFrozenAt ? null : frozenAt ?? this.frozenAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': 2,
        'id': id,
        'labelNumber': labelNumber,
        'initialAmountMl': initialAmountMl,
        'remainingAmountMl': remainingAmountMl,
        // Keep the legacy property for older installed app versions.
        'amountMl': remainingAmountMl,
        'expressedAt': expressedAt.toIso8601String(),
        'storageLocation': storageLocation.name,
        'sourceSide': sourceSide.name,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'frozenAt': frozenAt?.toIso8601String(),
      };

  factory MilkBatch.fromJson(Map<String, dynamic> json) {
    final legacyAmount = _readInt(json['amountMl']);
    final initialAmount =
        _readInt(json['initialAmountMl']) ?? legacyAmount ?? 0;
    final remainingAmount =
        _readInt(json['remainingAmountMl']) ?? legacyAmount ?? initialAmount;
    final status = MilkBatchStatus.values.firstWhere(
      (value) => value.name == json['status'],
      orElse: () => remainingAmount > 0
          ? MilkBatchStatus.active
          : MilkBatchStatus.depleted,
    );

    return MilkBatch(
      id: json['id'] as String,
      labelNumber: json['labelNumber'] as String,
      initialAmountMl: initialAmount,
      remainingAmountMl: remainingAmount,
      expressedAt: DateTime.parse(json['expressedAt'] as String),
      storageLocation: MilkStorageLocation.values.firstWhere(
        (value) => value.name == json['storageLocation'],
        orElse: () => MilkStorageLocation.refrigerator,
      ),
      sourceSide: MilkSourceSide.values.firstWhere(
        (value) => value.name == json['sourceSide'],
        orElse: () => MilkSourceSide.unspecified,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.parse(json['expressedAt'] as String),
      status: status,
      frozenAt: DateTime.tryParse(json['frozenAt'] as String? ?? ''),
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '');
  }
}

