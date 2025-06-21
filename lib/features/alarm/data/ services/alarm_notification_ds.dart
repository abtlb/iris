import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled3/core/services/local_notification_ds.dart';


class AlarmNotificationService{
  final LocalNotificationDataSource localNotificationDataSource;

  AlarmNotificationService(this.localNotificationDataSource);

  Future<void> initialize() async {
    const androidChannel = AndroidNotificationChannel(
      'alarm_channel',           // id
      'Alarm Notifications',     // name
      importance: Importance.max,
      description: 'Channel for scheduled alarm notifications',
    );
    await localNotificationDataSource.createChannel(androidChannel);
    Permission.notification.request();
    print("Notification status: ${await Permission.notification.status}");
  }

  static NotificationDetails _alarmDetails() {
    const android = AndroidNotificationDetails(
      'alarm_channel', 'Alarms',
      channelDescription: 'Channel for scheduled alarms',
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap('@drawable/android12splash'),
      icon: '@drawable/ic_stat_name',
      priority: Priority.max,
      playSound: false,
      enableVibration: false,
    );
    const iOS = DarwinNotificationDetails(presentSound: false);
    return const NotificationDetails(android: android, iOS: iOS);
  }

  Future<void> scheduleAlarmNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    return await localNotificationDataSource.schedule(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      details: _alarmDetails(),
      payload: id.toString(),
    );
  }

  Future<void> cancelAlarmNotification(int id) async {
    await localNotificationDataSource.cancel(id);
  }

  Stream<int> get onAlarmFired => localNotificationDataSource.onNotificationTapped
      .map((payload) {
    if (payload == null) throw StateError('Missing payload on alarm');
    final parsed = int.tryParse(payload);
    if (parsed == null) throw FormatException('Invalid alarm ID payload: $payload');
    return parsed;
  });
}
