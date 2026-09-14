import '../../core/data/record_identity.dart';
import 'feeding_entry.dart';

class FeedingSession {
  FeedingSession({
    String? id,
    this.childId = RecordIdentity.legacyChildId,
    required this.startTime,
    required this.endTime,
    required this.entries,
    this.startWeightGr,
    this.endWeightGr,
    this.milkIntakeGr,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? RecordIdentity.newId('feeding'),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String childId;
  final DateTime startTime;
  final DateTime endTime;
  final List<FeedingEntry> entries;
  final int? startWeightGr;
  final int? endWeightGr;
  final int? milkIntakeGr;
  final DateTime createdAt;
  final DateTime updatedAt;

  Duration get totalDuration =>
      entries.fold(Duration.zero, (sum, entry) => sum + entry.duration);

  Duration get leftDuration => entries
      .where((entry) => entry.side == FeedingSide.left)
      .fold(Duration.zero, (sum, entry) => sum + entry.duration);

  Duration get rightDuration => entries
      .where((entry) => entry.side == FeedingSide.right)
      .fold(Duration.zero, (sum, entry) => sum + entry.duration);

  double get leftRatio {
    final total = totalDuration.inSeconds;
    return total == 0 ? .5 : leftDuration.inSeconds / total;
  }

  int get totalMilkIntake => milkIntakeGr ?? 0;
  bool get hasMilkData => milkIntakeGr != null && milkIntakeGr! > 0;
  bool get isLongSession => totalDuration.inMinutes > 30;
  DateTime get endTimeSafe => entries.isNotEmpty ? endTime : startTime;

  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'id': id,
    'childId': childId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'entries': entries.map((entry) => entry.toJson()).toList(),
    'startWeightGr': startWeightGr,
    'endWeightGr': endWeightGr,
    'milkIntakeGr': milkIntakeGr,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory FeedingSession.fromJson(Map<String, dynamic> json) {
    final startTime = DateTime.parse(json['startTime'] as String);
    final endTime = DateTime.parse(json['endTime'] as String);
    return FeedingSession(
      id:
          json['id'] as String? ??
          RecordIdentity.legacyId('feeding', startTime),
      childId: json['childId'] as String? ?? RecordIdentity.legacyChildId,
      startTime: startTime,
      endTime: endTime,
      entries: (json['entries'] as List<dynamic>)
          .map(
            (entry) =>
                FeedingEntry.fromJson(Map<String, dynamic>.from(entry as Map)),
          )
          .toList(),
      startWeightGr: _readNullableInt(json['startWeightGr']),
      endWeightGr: _readNullableInt(json['endWeightGr']),
      milkIntakeGr: _readNullableInt(json['milkIntakeGr']),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? startTime,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? endTime,
    );
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }
}
