import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../features/care_calendar/care_event.dart';
import '../features/care_calendar/care_event_schedule.dart';

class CareNotificationService {
  CareNotificationService._();

  static final instance = CareNotificationService._();
  static const _notificationMapKey = 'care_notification_ids_v1';
  static const _permissionGrantedKey = 'care_notifications_permission_granted';
  static const _channelId = 'leyumi_care_reminders';
  static const _channelName = 'Care reminders';
  static const _channelDescription =
      'Reminders for care calendar appointments and medicine schedules.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final granted = androidGranted ?? iosGranted ?? true;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_permissionGrantedKey, granted);
    return granted;
  }

  Future<bool?> areNotificationsEnabled() async {
    await initialize();

    final androidEnabled = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.areNotificationsEnabled();
    if (androidEnabled != null) return androidEnabled;

    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_permissionGrantedKey);
  }

  Future<bool> canScheduleExactAlarms() async {
    await initialize();
    final android = _androidPlugin();
    if (android == null) return true;
    return await android.canScheduleExactNotifications() ?? false;
  }

  Future<bool> requestExactAlarmPermission() async {
    await initialize();
    final android = _androidPlugin();
    if (android == null) return true;
    return await android.requestExactAlarmsPermission() ?? false;
  }

  Future<bool> showTestNotification({
    required String title,
    required String body,
  }) async {
    await initialize();
    final granted = await requestPermissions();
    if (!granted) return false;

    await _plugin.show(
      900001,
      title,
      body,
      _notificationDetails(),
      payload: 'test',
    );
    return true;
  }

  Future<int> scheduleCareEvent({
    required CareEvent event,
    required bool enabled,
    required String reminderTitle,
  }) async {
    await initialize();
    await cancelCareEvent(event.id);

    if (!enabled ||
        event.status != CareEventStatus.scheduled ||
        event.reminderMinutesBefore == null) {
      return 0;
    }

    final granted = await requestPermissions();
    if (!granted) return 0;

    final now = DateTime.now();
    final reminderTimes = _reminderTimes(event, now);
    final ids = <int>[];
    final scheduleMode = await _scheduleMode();

    for (var index = 0; index < reminderTimes.length; index++) {
      final reminderAt = reminderTimes[index];
      final id = _notificationId(event.id, index);
      await _zonedSchedule(
        id,
        reminderTitle,
        _notificationBody(event),
        tz.TZDateTime.from(reminderAt.toUtc(), tz.UTC),
        scheduleMode: scheduleMode,
        payload: event.id,
      );
      ids.add(id);
    }

    if (ids.isNotEmpty) await _rememberIds(event.id, ids);
    return ids.length;
  }

  Future<void> cancelCareEvent(String eventId) async {
    await initialize();
    final preferences = await SharedPreferences.getInstance();
    final ids = preferences.getStringList(_mapKey(eventId)) ?? const [];
    for (final raw in ids) {
      final id = int.tryParse(raw);
      if (id != null) await _plugin.cancel(id);
    }
    await preferences.remove(_mapKey(eventId));
  }

  Future<void> _zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime date, {
    required AndroidScheduleMode scheduleMode,
    required String payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        date,
        _notificationDetails(),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (_) {
      if (scheduleMode == AndroidScheduleMode.inexactAllowWhileIdle) rethrow;
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        date,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    final android = _androidPlugin();
    if (android == null) return AndroidScheduleMode.exactAllowWhileIdle;

    final canScheduleExact = await android.canScheduleExactNotifications();
    if (canScheduleExact == true)
      return AndroidScheduleMode.exactAllowWhileIdle;

    final granted = await android.requestExactAlarmsPermission();
    return granted == true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  AndroidFlutterLocalNotificationsPlugin? _androidPlugin() {
    return _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }

  List<DateTime> _reminderTimes(CareEvent event, DateTime now) {
    final minutesBefore = event.reminderMinutesBefore;
    if (minutesBefore == null) return [];

    final occurrenceLimit = switch (event.recurrence) {
      CareEventRecurrence.none => 1,
      CareEventRecurrence.daily => 30,
      CareEventRecurrence.weekly => 16,
      CareEventRecurrence.monthly => 12,
    };
    final times = <DateTime>[];
    var searchFrom = now.add(Duration(minutes: minutesBefore));

    for (var index = 0; index < occurrenceLimit; index++) {
      final occurrence = CareEventSchedule.nextOccurrence(event, searchFrom);
      if (occurrence == null) break;

      final reminderAt = occurrence.subtract(Duration(minutes: minutesBefore));
      if (reminderAt.isAfter(now)) times.add(reminderAt);
      searchFrom = occurrence.add(const Duration(minutes: 1));
    }

    return times;
  }

  String _notificationBody(CareEvent event) {
    final details = <String>[
      event.title,
      if (event.dosage != null) event.dosage!,
      if (event.location != null) event.location!,
    ];
    return details.join(' - ');
  }

  int _notificationId(String eventId, int occurrenceIndex) {
    var hash = 0;
    for (final unit in eventId.codeUnits) {
      hash = ((hash * 31) + unit) & 0x3fffffff;
    }
    final id = (hash + occurrenceIndex + 1) & 0x3fffffff;
    return id == 0 ? occurrenceIndex + 1 : id;
  }

  Future<void> _rememberIds(String eventId, List<int> ids) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _mapKey(eventId),
      ids.map((id) => id.toString()).toList(),
    );
  }

  String _mapKey(String eventId) => '$_notificationMapKey:$eventId';
}
