// Local push notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    
    // Request permissions for Android 13+ and iOS
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    await _createChannels();
  }

  static Future<void> _createChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'cc_briefs',
        'Meeting Briefs',
        importance: Importance.high,
      ),
    );

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'cc_tasks',
        'Task Alerts',
        importance: Importance.defaultImportance,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'cc_heartbeat',
        'Heartbeat Service',
        importance: Importance.low,
      ),
    );
  }

  static bool _notificationsEnabled() {
    if (!Hive.isBoxOpen('settings')) return true;
    return Hive.box('settings').get('notifications', defaultValue: true);
  }

  static Future<void> sendBrief({
    required String title,
    required String body,
  }) async {
    if (!_notificationsEnabled()) return;

    await _plugin.show(
      1000 + DateTime.now().millisecond,
      '📋 Brief Ready: $title',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cc_briefs',
          'Meeting Briefs',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> sendTaskNudge({
    required String title,
    required String nudge,
    required int id,
  }) async {
    if (!_notificationsEnabled()) return;

    await _plugin.show(
      2000 + id,
      '⏰ Stale Task: $title',
      nudge,
      const NotificationDetails(
        android: AndroidNotificationDetails('cc_tasks', 'Task Alerts'),
      ),
    );
  }
}
