import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _onNotificationTap();
      },
    );
  }

  static void Function()? onNotificationTapCallback;

  static void _onNotificationTap() {
    onNotificationTapCallback?.call();
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'sound_alerts',
      'Sound Alerts',
      channelDescription: 'Alerts for detected sound events',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false, // No sound
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 1000]), // Custom vibration
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(0, title, body, notificationDetails);
  }
}