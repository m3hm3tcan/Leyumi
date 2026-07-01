import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FeedingNotificationService {
  FeedingNotificationService._();

  static final instance = FeedingNotificationService._();

  static const _notificationId = 910001;
  static const _channelId = 'leyumi_active_feeding';
  static const _channelName = 'Active feeding';
  static const _channelDescription =
      'Persistent notification while a feeding session is active.';

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

    return androidGranted ?? iosGranted ?? true;
  }

  Future<void> showActiveFeeding({
    required String title,
    required String body,
    required DateTime startedAt,
  }) async {
    await initialize();
    final granted = await requestPermissions();
    if (!granted) return;

    await _plugin.show(
      _notificationId,
      title,
      body,
      _notificationDetails(startedAt),
      payload: 'active_feeding',
    );
  }

  Future<void> cancelActiveFeeding() async {
    await initialize();
    await _plugin.cancel(_notificationId);
  }

  NotificationDetails _notificationDetails(DateTime startedAt) {
    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      category: AndroidNotificationCategory.status,
      autoCancel: false,
      ongoing: true,
      onlyAlertOnce: true,
      showWhen: true,
      when: startedAt.millisecondsSinceEpoch,
      usesChronometer: true,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );
    return NotificationDetails(android: android, iOS: ios);
  }
}
