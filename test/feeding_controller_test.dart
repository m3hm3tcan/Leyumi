import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/feeding/feeding_controller.dart';
import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';

void main() {
  test('builds a finished session without clearing the persisted draft', () {
    final startedAt = DateTime.utc(2026, 8, 20, 10);
    final draft = FeedingSession(
      id: 'feeding-1',
      childId: 'child-1',
      startTime: startedAt,
      endTime: startedAt,
      entries: [
        FeedingEntry(side: FeedingSide.left, duration: Duration(minutes: 8)),
      ],
      startWeightGr: 6200,
      createdAt: startedAt,
      updatedAt: startedAt,
    );
    final controller = FeedingController(onTick: (_) {});
    addTearDown(controller.dispose);
    controller.restoreDraft(
      session: draft,
      draftActiveSide: null,
      draftActiveSideStartedAt: null,
      draftStartWeightGr: 6200,
      draftEndWeightGr: null,
    );
    controller.setEndWeight(6240);

    final completed = controller.createFinishedSession();

    expect(controller.currentSession, same(draft));
    expect(completed.id, draft.id);
    expect(completed.milkIntakeGr, 40);
    controller.clearSession();
    expect(controller.currentSession, isNull);
  });
}
