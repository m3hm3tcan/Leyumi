import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/logging/app_logger.dart';

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
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    try {
      await initialize();

      final androidGranted = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return androidGranted ?? true;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Notification permission could not be requested.',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> showActiveFeeding({
    required String title,
    required String body,
    required DateTime startedAt,
  }) async {
    try {
      final granted = await requestPermissions();
      if (!granted) return;

      await _plugin.show(
        id: _notificationId,
        title: title,
        body: body,
        notificationDetails: _notificationDetails(startedAt),
        payload: 'active_feeding',
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'The active feeding notification could not be shown.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> cancelActiveFeeding() async {
    try {
      await initialize();
      await _plugin.cancel(id: _notificationId);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'The active feeding notification could not be cancelled.',
        error: error,
        stackTrace: stackTrace,
      );
    }
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
    return NotificationDetails(android: android);
  }
}
