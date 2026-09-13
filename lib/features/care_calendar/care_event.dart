import '../../core/data/record_identity.dart';

enum CareEventType { routine, plan, reminder, care, activity, support, custom }

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
    int? reminderMinutesBefore,
    bool clearLocation = false,
    bool clearNote = false,
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
      reminderMinutesBefore: clearReminder
          ? null
          : reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'id': id,
    'childId': childId,
    'type': type.name,
    'title': title,
    'scheduledAt': scheduledAt.toIso8601String(),
    'status': status.name,
    'recurrence': recurrence.name,
    'location': location,
    'note': note,
    'reminderMinutesBefore': reminderMinutesBefore,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CareEvent.fromJson(Map<String, dynamic> json) {
    final scheduledAt = DateTime.parse(json['scheduledAt'] as String);
    return CareEvent(
      id: json['id'] as String? ?? RecordIdentity.legacyId('care', scheduledAt),
      childId: json['childId'] as String? ?? RecordIdentity.legacyChildId,
      type: _eventTypeFromStoredName(json['type'] as String?),
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
      reminderMinutesBefore: (json['reminderMinutesBefore'] as num?)?.round(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? scheduledAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? scheduledAt,
    );
  }
}

CareEventType _eventTypeFromStoredName(String? name) => switch (name) {
  // Compatibility with calendar records created before the categories were
  // simplified into general planning categories.
  'vaccine' => CareEventType.routine,
  'appointment' => CareEventType.plan,
  'medicine' => CareEventType.reminder,
  'checkup' => CareEventType.care,
  'laboratory' => CareEventType.activity,
  'therapy' => CareEventType.support,
  'routine' => CareEventType.routine,
  'plan' => CareEventType.plan,
  'reminder' => CareEventType.reminder,
  'care' => CareEventType.care,
  'activity' => CareEventType.activity,
  'support' => CareEventType.support,
  _ => CareEventType.custom,
};
