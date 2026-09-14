import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/care_calendar/care_event.dart';

void main() {
  test('planned events and reminders survive a JSON round trip', () {
    final scheduledAt = DateTime.utc(2026, 8, 21, 9, 30);
    final event = CareEvent(
      id: 'care-1',
      childId: 'child-1',
      type: CareEventType.plan,
      title: 'Family plan',
      scheduledAt: scheduledAt,
      location: 'City park',
      reminderMinutesBefore: 60,
      createdAt: scheduledAt,
      updatedAt: scheduledAt,
    );

    final restored = CareEvent.fromJson(event.toJson());

    expect(restored.type, CareEventType.plan);
    expect(restored.title, event.title);
    expect(restored.location, event.location);
    expect(restored.scheduledAt, scheduledAt);
    expect(restored.reminderMinutesBefore, 60);
  });

  test('legacy medical category names migrate to general categories', () {
    final restored = CareEvent.fromJson({
      'id': 'legacy-care-1',
      'childId': 'child-1',
      'type': 'vaccine',
      'title': 'Old record',
      'scheduledAt': DateTime.utc(2026, 8, 21).toIso8601String(),
    });

    expect(restored.type, CareEventType.routine);
    expect(restored.toJson()['type'], 'routine');
  });
}
