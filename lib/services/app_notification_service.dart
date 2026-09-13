import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/logging/app_logger.dart';

class AppNotificationService {
  AppNotificationService._();

  static final instance = AppNotificationService._();

  static const _activeFeedingId = 910001;
  static const _activeFeedingChannelId = 'leyumi_active_timer_v2';
  static const _careChannelId = 'leyumi_activity_reminders';
  static const _generalChannelId = 'leyumi_general';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Future<void>? _initializing;

  Future<void> initialize() {
    if (_initialized) return Future.value();
    final inProgress = _initializing;
    if (inProgress != null) return inProgress;

    final task = _initialize();
    _initializing = task;
    return task.whenComplete(() => _initializing = null);
  }

  Future<void> _initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> notificationsEnabled() async {
    try {
      await initialize();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? true;
    } catch (error, stackTrace) {
      _logFailure(
        'Notification permission could not be checked.',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      await initialize();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (await android?.areNotificationsEnabled() ?? true) return true;
      return await android?.requestNotificationsPermission() ?? true;
    } catch (error, stackTrace) {
      _logFailure(
        'Notification permission could not be requested.',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> openNotificationSettings() async {
    try {
      await initialize();
      return await _plugin.openAppNotificationSettings() ?? false;
    } catch (error, stackTrace) {
      _logFailure(
        'Notification settings could not be opened.',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> showTestNotification({
    required String title,
    required String body,
  }) async {
    try {
      if (!await requestPermissions()) return false;
      await _plugin.show(
        id: 910002,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _generalChannelId,
            'Leyumi notifications',
            channelDescription: 'General notifications from Leyumi.',
            icon: 'ic_notification',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: 'notification_test',
      );
      return true;
    } catch (error, stackTrace) {
      _logFailure(
        'The test notification could not be shown.',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> scheduleCareReminder({
    required String eventId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required int minutesBefore,
  }) async {
    final reminderAt = scheduledAt.subtract(Duration(minutes: minutesBefore));
    if (!reminderAt.isAfter(DateTime.now())) return false;

    try {
      if (!await requestPermissions()) return false;
      final id = notificationIdForEvent(eventId);
      await _plugin.cancel(id: id);
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(reminderAt.toUtc(), tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _careChannelId,
            'Activity reminders',
            channelDescription: 'Reminders for activities planned in Leyumi.',
            icon: 'ic_notification',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'care_event:$eventId',
      );
      return true;
    } catch (error, stackTrace) {
      _logFailure(
        'The activity reminder could not be scheduled.',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<void> cancelCareReminder(String eventId) async {
    try {
      await initialize();
      await _plugin.cancel(id: notificationIdForEvent(eventId));
    } catch (error, stackTrace) {
      _logFailure(
        'The activity reminder could not be cancelled.',
        error,
        stackTrace,
      );
    }
  }

  Future<void> showActiveFeeding({
    required String title,
    required String body,
    required DateTime startedAt,
  }) async {
    try {
      if (!await requestPermissions()) return;
      await _plugin.show(
        id: _activeFeedingId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _activeFeedingChannelId,
            'Active timer',
            channelDescription:
                'Persistent notification while a timer is active.',
            icon: 'ic_notification',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            category: AndroidNotificationCategory.status,
            autoCancel: false,
            ongoing: true,
            onlyAlertOnce: true,
            showWhen: true,
            when: startedAt.millisecondsSinceEpoch,
            usesChronometer: true,
          ),
        ),
        payload: 'active_feeding',
      );
    } catch (error, stackTrace) {
      _logFailure(
        'The active timer notification could not be shown.',
        error,
        stackTrace,
      );
    }
  }

  Future<void> cancelActiveFeeding() async {
    try {
      await initialize();
      await _plugin.cancel(id: _activeFeedingId);
    } catch (error, stackTrace) {
      _logFailure(
        'The active timer notification could not be cancelled.',
        error,
        stackTrace,
      );
    }
  }

  int notificationIdForEvent(String eventId) {
    var hash = 0x811c9dc5;
    for (final codeUnit in eventId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return 100000 + (hash % 2000000000);
  }

  void _logFailure(String message, Object error, StackTrace stackTrace) {
    AppLogger.warning(message, error: error, stackTrace: stackTrace);
  }
}
