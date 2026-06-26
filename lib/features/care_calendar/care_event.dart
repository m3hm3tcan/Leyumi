import '../../core/data/record_identity.dart';

enum CareEventType {
  vaccine,
  doctor,
  medicine,
  checkup,
  laboratory,
  therapy,
  custom,
}

enum CareEventStatus { scheduled, completed, cancelled }

enum CareEventRecurrence { none, daily, weekly, monthly }

class CareEvent {
  CareEvent({
    String? id,
    required this.childId,
    required this.type,
    required this.title,
    required this.scheduledAt,
    this.status = CareEventStatus.scheduled,
    this.recurrence = CareEventRecurrence.none,
    this.location,
    this.note,
    this.dosage,
    this.reminderMinutesBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? RecordIdentity.newId('care'),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String childId;
  final CareEventType type;
  final String title;
  final DateTime scheduledAt;
  final CareEventStatus status;
  final CareEventRecurrence recurrence;
  final String? location;
  final String? note;
  final String? dosage;
  final int? reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  CareEvent copyWith({
    CareEventType? type,
    String? title,
    DateTime? scheduledAt,
    CareEventStatus? status,
    CareEventRecurrence? recurrence,
    String? location,
    String? note,
    String? dosage,
    int? reminderMinutesBefore,
    bool clearLocation = false,
    bool clearNote = false,
    bool clearDosage = false,
    bool clearReminder = false,
  }) {
    return CareEvent(
      id: id,
      childId: childId,
      type: type ?? this.type,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      recurrence: recurrence ?? this.recurrence,
      location: clearLocation ? null : location ?? this.location,
      note: clearNote ? null : note ?? this.note,
      dosage: clearDosage ? null : dosage ?? this.dosage,
      reminderMinutesBefore: clearReminder
          ? null
          : reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'id': id,
    'childId': childId,
    'type': type.name,
    'title': title,
    'scheduledAt': scheduledAt.toIso8601String(),
    'status': status.name,
    'recurrence': recurrence.name,
    'location': location,
    'note': note,
    'dosage': dosage,
    'reminderMinutesBefore': reminderMinutesBefore,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CareEvent.fromJson(Map<String, dynamic> json) {
    final scheduledAt = DateTime.parse(json['scheduledAt'] as String);
    return CareEvent(
      id: json['id'] as String? ?? RecordIdentity.legacyId('care', scheduledAt),
      childId: json['childId'] as String? ?? RecordIdentity.legacyChildId,
      type: CareEventType.values.byName(
        json['type'] as String? ?? CareEventType.custom.name,
      ),
      title: json['title'] as String,
      scheduledAt: scheduledAt,
      status: CareEventStatus.values.byName(
        json['status'] as String? ?? CareEventStatus.scheduled.name,
      ),
      recurrence: CareEventRecurrence.values.byName(
        json['recurrence'] as String? ?? CareEventRecurrence.none.name,
      ),
      location: json['location'] as String?,
      note: json['note'] as String?,
      dosage: json['dosage'] as String?,
      reminderMinutesBefore: (json['reminderMinutesBefore'] as num?)?.round(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? scheduledAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? scheduledAt,
    );
  }
}
