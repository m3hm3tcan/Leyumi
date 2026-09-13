import 'dart:io';

import 'package:leyumi/core/database/app_database.dart';
import 'package:leyumi/features/care_calendar/care_event.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/models/baby_profile.dart';
import 'package:leyumi/models/growth_entry.dart';
import 'package:leyumi/services/baby_storage.dart';
import 'package:leyumi/services/backup_service.dart';
import 'package:leyumi/services/care_event_storage.dart';
import 'package:leyumi/services/diaper_storage.dart';
import 'package:leyumi/services/feeding_storage.dart';
import 'package:leyumi/services/growth_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _childId = 'demo-child-defne';
const _password = 'LeyumiDemo2026!';

Future<void> main() async {
  sqfliteFfiInit();
  await AppDatabase.configureForTesting(
    factory: databaseFactoryFfi,
    databasePath: inMemoryDatabasePath,
  );

  try {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = today.subtract(const Duration(days: 13));
    final birthDate = today.subtract(const Duration(days: 155));
    final profileCreatedAt = firstDay.subtract(const Duration(days: 1));

    await BabyStorage().saveProfile(
      BabyProfile(
        id: _childId,
        name: 'Defne',
        gender: 'Female',
        birthDate: birthDate,
        birthWeight: 3350,
        birthHeight: 50,
        weight: 6950,
        height: 65,
        headCircumference: 42,
        createdAt: profileCreatedAt,
        updatedAt: now,
      ),
    );

    final feedingStorage = FeedingStorage();
    final diaperStorage = DiaperStorage();
    var feedingCount = 0;
    var diaperCount = 0;

    const feedingHours = [1, 5, 9, 13, 17, 21];
    const diaperHours = [0, 4, 7, 11, 15, 19, 22];
    const diaperTypes = [
      DiaperType.pee,
      DiaperType.both,
      DiaperType.pee,
      DiaperType.pee,
      DiaperType.poop,
      DiaperType.pee,
      DiaperType.both,
    ];

    for (var dayIndex = 0; dayIndex < 14; dayIndex++) {
      final day = firstDay.add(Duration(days: dayIndex));

      for (var slot = 0; slot < feedingHours.length; slot++) {
        final start = DateTime(
          day.year,
          day.month,
          day.day,
          feedingHours[slot],
          8 + ((dayIndex * 7 + slot * 11) % 38),
        );
        final leftMinutes = 8 + ((dayIndex + slot * 2) % 6);
        final rightMinutes = 7 + ((dayIndex * 2 + slot) % 6);
        final end = start.add(Duration(minutes: leftMinutes + rightMinutes));
        if (end.isAfter(now.subtract(const Duration(minutes: 5)))) continue;

        await feedingStorage.saveSession(
          FeedingSession(
            id: 'demo-feeding-$dayIndex-$slot',
            childId: _childId,
            startTime: start,
            endTime: end,
            entries: [
              FeedingEntry(
                side: FeedingSide.left,
                duration: Duration(minutes: leftMinutes),
              ),
              FeedingEntry(
                side: FeedingSide.right,
                duration: Duration(minutes: rightMinutes),
              ),
            ],
            createdAt: end,
            updatedAt: end,
          ),
        );
        feedingCount++;
      }

      for (var slot = 0; slot < diaperHours.length; slot++) {
        final timestamp = DateTime(
          day.year,
          day.month,
          day.day,
          diaperHours[slot],
          5 + ((dayIndex * 13 + slot * 9) % 47),
        );
        if (timestamp.isAfter(now.subtract(const Duration(minutes: 5)))) {
          continue;
        }
        final type = diaperTypes[(dayIndex + slot) % diaperTypes.length];
        await diaperStorage.addEntry(
          DiaperEntry(
            id: 'demo-diaper-$dayIndex-$slot',
            childId: _childId,
            timestamp: timestamp,
            type: type,
            peeAmount: type == DiaperType.poop ? null : PeeAmount.medium,
            poopAmount: type == DiaperType.pee ? null : PoopAmount.medium,
            poopColor: type == DiaperType.pee ? null : PoopColor.mustardYellow,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
        diaperCount++;
      }
    }

    final growthStorage = GrowthStorage();
    final growthMeasurements = <GrowthEntry>[
      GrowthEntry(
        id: 'demo-growth-1',
        childId: _childId,
        date: firstDay,
        weight: 6800,
        height: 64,
        headCircumference: 41,
        createdAt: firstDay,
        updatedAt: firstDay,
      ),
      GrowthEntry(
        id: 'demo-growth-2',
        childId: _childId,
        date: firstDay.add(const Duration(days: 7)),
        weight: 6880,
        height: 65,
        headCircumference: 42,
        createdAt: firstDay.add(const Duration(days: 7)),
        updatedAt: firstDay.add(const Duration(days: 7)),
      ),
      GrowthEntry(
        id: 'demo-growth-3',
        childId: _childId,
        date: today,
        weight: 6950,
        height: 65,
        headCircumference: 42,
        createdAt: today,
        updatedAt: today,
      ),
    ];
    for (final entry in growthMeasurements) {
      await growthStorage.addEntry(entry);
    }

    final careStorage = CareEventStorage();
    final careEvents = <CareEvent>[
      CareEvent(
        id: 'demo-care-1',
        childId: _childId,
        type: CareEventType.routine,
        title: 'Banyo zamanı',
        scheduledAt: today
            .subtract(const Duration(days: 6))
            .add(const Duration(hours: 19)),
        status: CareEventStatus.completed,
        createdAt: firstDay,
        updatedAt: today.subtract(const Duration(days: 6)),
      ),
      CareEvent(
        id: 'demo-care-2',
        childId: _childId,
        type: CareEventType.activity,
        title: 'Aile yürüyüşü',
        scheduledAt: today
            .subtract(const Duration(days: 2))
            .add(const Duration(hours: 16)),
        status: CareEventStatus.completed,
        createdAt: firstDay,
        updatedAt: today.subtract(const Duration(days: 2)),
      ),
      CareEvent(
        id: 'demo-care-3',
        childId: _childId,
        type: CareEventType.plan,
        title: 'Haftalık ölçüm',
        scheduledAt: today.add(const Duration(days: 2, hours: 10)),
        reminderMinutesBefore: 60,
        createdAt: now,
        updatedAt: now,
      ),
      CareEvent(
        id: 'demo-care-4',
        childId: _childId,
        type: CareEventType.support,
        title: 'Aile ziyareti',
        scheduledAt: today.add(const Duration(days: 4, hours: 14)),
        reminderMinutesBefore: 120,
        createdAt: now,
        updatedAt: now,
      ),
      CareEvent(
        id: 'demo-care-5',
        childId: _childId,
        type: CareEventType.routine,
        title: 'Banyo zamanı',
        scheduledAt: today.add(const Duration(days: 6, hours: 19)),
        recurrence: CareEventRecurrence.weekly,
        reminderMinutesBefore: 30,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    for (final event in careEvents) {
      await careStorage.save(event);
    }

    final backupService = BackupService();
    final bytes = await backupService.createBackup(_password);
    final preview = await backupService.prepareRestore(bytes, _password);
    final output = File('build/demo/leyumi-demo-14-gun.leyumi');
    await output.parent.create(recursive: true);
    await output.writeAsBytes(bytes, flush: true);

    stdout.writeln('Demo backup created: ${output.absolute.path}');
    stdout.writeln('Password: $_password');
    stdout.writeln(
      'Records: $feedingCount feeding, $diaperCount diaper, '
      '${growthMeasurements.length + 1} growth, ${careEvents.length} calendar',
    );
    stdout.writeln(
      'Backup preview: ${preview.preview.profileCount} profile, '
      '${preview.preview.recordCount} records',
    );
  } finally {
    await AppDatabase.close();
  }
}
