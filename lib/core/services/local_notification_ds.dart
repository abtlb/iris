import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class LocalNotificationDataSource {
  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String?> _tapController = StreamController.broadcast();

  static const int _max32 = 0x7fffffff; // 2^31 - 1
  int _to32(int id) => id & _max32;      // bitwise AND keeps it in 32-bit range

  LocalNotificationDataSource(this._plugin) {
    _initialize();
  }

  /// Initialize the notification plugin and create default channels
  Future<void> _initialize() async {
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_name'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        print("OnDidReceiveNotificationResponse is called with payload: ${response.payload}");
        _tapController.add(response.payload);
      },
    );

    // Create default notification channel
    await _createDefaultChannel();
  }

  /// Create the default notification channel
  Future<void> _createDefaultChannel() async {
    const channel = AndroidNotificationChannel(
      'default_channel',
      'General Notifications',
      description: 'General notifications for the app',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await createChannel(channel);
  }

  /// Request all necessary permissions for notifications
  Future<bool> requestNotificationPermissions() async {
    print("Requesting notification permissions...");

    // Request notification permission (Android 13+)
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        print("Notification permission denied");
        return false;
      }
    }

    // Request exact alarm permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      print("Exact alarm permission needed - opening settings");
      await openExactAlarmSettings();

      // Wait a bit and check again
      await Future.delayed(const Duration(seconds: 1));
      if (await Permission.scheduleExactAlarm.isDenied) {
        print("Exact alarm permission still denied");
        return false;
      }
    }

    print("All permissions granted");
    return true;
  }

  /// Show an immediate notification
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationDetails? details,
  }) async {
    print("Showing immediate notification: $title");

    // Ensure permissions are granted
    if (!await requestNotificationPermissions()) {
      print("Cannot show notification - permissions not granted");
      return;
    }

    try {
      await _plugin.show(
          _to32(id),
          title,
          body,
          details ?? _defaultDetails(),
          payload: payload
      );
      print("Notification shown successfully");
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  /// Schedule a notification for a specific time
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationDetails? details,
  }) async {
    print("Scheduling notification: $title for $scheduledTime");
    print("Current time: ${DateTime.now()}");

    // Check if scheduled time is in the future
    if (scheduledTime.isBefore(DateTime.now())) {
      print("Error: Scheduled time is in the past");
      return;
    }

    // Ensure permissions are granted
    if (!await requestNotificationPermissions()) {
      print("Cannot schedule notification - permissions not granted");
      return;
    }

    try {
      await _plugin.zonedSchedule(
        _to32(id),
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details ?? _defaultDetails(),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print("Notification scheduled successfully");

      // Debug: Check pending notifications
      await _debugPendingNotifications();
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancel(int id) async {
    print("Cancelling notification with id: $id");

    try {
      await _plugin.cancel(_to32(id));
      print("Notification cancelled successfully");
    } catch (e) {
      print("Error cancelling notification: $e");
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    print("Cancelling all notifications");

    try {
      await _plugin.cancelAll();
      print("All notifications cancelled successfully");
    } catch (e) {
      print("Error cancelling all notifications: $e");
    }
  }

  /// Get pending notification requests (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  /// Debug method to print pending notifications
  Future<void> _debugPendingNotifications() async {
    final pending = await getPendingNotifications();
    print("Pending notifications count: ${pending.length}");
    for (final notification in pending) {
      print("  - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}");
    }
  }

  /// Stream of notification taps
  Stream<String?> get onNotificationTapped => _tapController.stream;

  /// Default notification details with high priority
  NotificationDetails _defaultDetails() {
    const android = AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      channelDescription: 'General notifications for the app',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      icon: '@drawable/ic_stat_name', // Add this line
      largeIcon: DrawableResourceAndroidBitmap('@drawable/android12splash'),
      when: null,
      usesChronometer: false,
      chronometerCountDown: false,
      channelShowBadge: true,
      onlyAlertOnce: false,
      ongoing: false,
      autoCancel: true,
      silent: false,
      colorized: false,
    );

    const iOS = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(android: android, iOS: iOS);
  }

  /// Open exact alarm settings for Android
  Future<void> openExactAlarmSettings() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      print("Exact alarm permission already granted");
      return;
    }

    print("Opening exact alarm settings");

    try {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      print("Error opening exact alarm settings: $e");

      // Fallback to general app settings
      try {
        const fallbackIntent = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await fallbackIntent.launch();
      } catch (e2) {
        print("Error opening app settings: $e2");
      }
    }
  }

  /// Create a custom notification channel
  Future<void> createChannel(AndroidNotificationChannel androidChannel) async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      print("Notification channel created: ${androidChannel.id}");
    } catch (e) {
      print("Error creating notification channel: $e");
    }
  }

  /// Test method to verify notifications are working
  Future<void> testNotification() async {
    print("Testing immediate notification...");
    await show(
      id: 999999,
      title: "Test Notification",
      body: "If you see this, notifications are working!",
      payload: "test_payload",
    );
  }

  /// Dispose resources
  void dispose() {
    _tapController.close();
  }
}