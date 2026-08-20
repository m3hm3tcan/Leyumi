import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/care_calendar/care_event.dart';

void main() {
  test('appointment care events survive a JSON round trip', () {
    final scheduledAt = DateTime.utc(2026, 8, 21, 9, 30);
    final event = CareEvent(
      id: 'care-1',
      childId: 'child-1',
      type: CareEventType.appointment,
      title: 'Routine appointment',
      scheduledAt: scheduledAt,
      location: 'Clinic A',
      createdAt: scheduledAt,
      updatedAt: scheduledAt,
    );

    final restored = CareEvent.fromJson(event.toJson());

    expect(restored.type, CareEventType.appointment);
    expect(restored.title, event.title);
    expect(restored.location, event.location);
    expect(restored.scheduledAt, scheduledAt);
  });
}
