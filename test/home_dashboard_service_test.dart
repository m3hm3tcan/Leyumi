import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/features/home/home_dashboard_service.dart';
import 'package:leyumi/services/diaper_storage.dart';
import 'package:leyumi/services/feeding_storage.dart';

import 'sqlite_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(SqliteTestSupport.setUp);
  tearDown(SqliteTestSupport.tearDown);

  test('loads only the active dashboard day and requested child', () async {
    final now = DateTime(2026, 8, 23, 18);
    final feedings = FeedingStorage();
    final diapers = DiaperStorage();

    await feedings.saveSession(
      _feeding('f-old', 'child-1', DateTime(2026, 8, 22, 23), 5),
    );
    await feedings.saveSession(
      _feeding('f-1', 'child-1', DateTime(2026, 8, 23, 9), 12),
    );
    await feedings.saveSession(
      _feeding('f-2', 'child-1', DateTime(2026, 8, 23, 15), 18),
    );
    await feedings.saveSession(
      _feeding('f-other', 'child-2', DateTime(2026, 8, 23, 17), 40),
    );
    await diapers.addEntry(
      _diaper('d-1', 'child-1', DateTime(2026, 8, 23, 10), DiaperType.pee),
    );
    await diapers.addEntry(
      _diaper('d-2', 'child-1', DateTime(2026, 8, 23, 16), DiaperType.both),
    );
    await diapers.addEntry(
      _diaper('d-other', 'child-2', DateTime(2026, 8, 23, 17), DiaperType.poop),
    );

    final result = await const HomeDashboardService().load(
      childId: 'child-1',
      now: now,
    );

    expect(result.todayFeedingCount, 2);
    expect(result.todayFeedingDuration, const Duration(minutes: 30));
    expect(result.todayDiaperCount, 2);
    expect(result.todayPeeDiaperCount, 2);
    expect(result.todayPoopDiaperCount, 1);
    expect(result.lastFeeding?.id, 'f-2');
    expect(result.lastDiaper?.id, 'd-2');
    expect(result.lastActivity, DateTime(2026, 8, 23, 16));
  });

  test('keeps latest records visible when today has no entries', () async {
    final feedings = FeedingStorage();
    await feedings.saveSession(
      _feeding('f-yesterday', 'child-1', DateTime(2026, 8, 22, 20), 8),
    );

    final result = await const HomeDashboardService().load(
      childId: 'child-1',
      now: DateTime(2026, 8, 23, 10),
    );

    expect(result.todayFeedingCount, 0);
    expect(result.todayDiaperCount, 0);
    expect(result.lastFeeding?.id, 'f-yesterday');
    expect(result.lastDiaper, isNull);
  });
}

FeedingSession _feeding(
  String id,
  String childId,
  DateTime start,
  int minutes,
) => FeedingSession(
  id: id,
  childId: childId,
  startTime: start,
  endTime: start.add(Duration(minutes: minutes)),
  entries: [
    FeedingEntry(
      side: FeedingSide.left,
      duration: Duration(minutes: minutes),
    ),
  ],
  createdAt: start,
  updatedAt: start,
);

DiaperEntry _diaper(
  String id,
  String childId,
  DateTime timestamp,
  DiaperType type,
) => DiaperEntry(
  id: id,
  childId: childId,
  timestamp: timestamp,
  type: type,
  peeAmount: type == DiaperType.poop ? null : PeeAmount.medium,
  poopAmount: type == DiaperType.pee ? null : PoopAmount.medium,
  createdAt: timestamp,
  updatedAt: timestamp,
);
