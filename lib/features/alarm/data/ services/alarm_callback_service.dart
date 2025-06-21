import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/features/alarm/data/%20services/flash_service.dart';
import 'package:untitled3/features/alarm/data/%20services/vibration_service.dart';
import 'package:untitled3/main.dart';

import '../../../../core/widgets/all_parent_widget.dart';
import '../../domain/entities/alarm_entity.dart';

@pragma('vm:entry-point')
Future<void> alarmCallback(int id, Map<String, dynamic> params) async {
  print("=== ALARM CALLBACK STARTED ===");
  print("Alarm ID: $id");
  print("Params: $params");

  ReceivePort? dismissPort;
  // FlashService? flashService;
  // VibrationService? vibrationService;
  Timer? timeoutTimer;

  try {
    var label = params['label'] as String;
    var pattern = params['pattern'] as int;

    // print("Starting flash and vibration services");
    // flashService = FlashService();
    // vibrationService = VibrationService();

    // flashService.start(pattern);
    // vibrationService.start(pattern);

    // Register dismiss port with unique name per alarm
    // dismissPort = ReceivePort();
    // final portName = 'alarm_dismiss_port_$id';
    //
    // // Clean up any existing port with this name first
    // IsolateNameServer.removePortNameMapping(portName);

    // final registered = IsolateNameServer.registerPortWithName(
    //   dismissPort.sendPort,
    //   portName,
    // );
    //
    // if (!registered) {
    //   print("❌ Failed to register dismiss port: $portName");
    //   // Continue anyway, but dismiss won't work
    // } else {
    //   print("✅ Registered dismiss port: $portName");
    // }

    // Send message to UI (non-blocking)
    _sendMessageToUI(id, label, pattern);

    // // Set up timeout for auto-dismiss (5 minutes)
    // timeoutTimer = Timer(const Duration(minutes: 5), () {
    //   print("⏰ Alarm auto-dismissed after timeout");
    //   dismissPort?.close();
    // });
    //
    // print("Waiting for dismiss signal...");
    // // Wait for dismiss signal or timeout
    // try {
    //   await dismissPort.firstWhere((msg) {
    //     print("Received dismiss port message: $msg");
    //     return msg == 'dismiss' || msg.toString().contains('dismiss');
    //   }).timeout(
    //     const Duration(minutes: 5),
    //     onTimeout: () {
    //       print("⏰ Dismiss timeout reached");
    //       return 'timeout';
    //     },
    //   );
    //   print("✅ Received dismiss signal or timeout");
    // } catch (e) {
    //   print("⚠️ Error waiting for dismiss: $e");
    // }

  } catch(e, stackTrace) {
    print("❌ Error in alarmCallback: $e");
    print("Stack trace: $stackTrace");
  }
  // finally {
  //   // Clean up everything
  //   print("🧹 Cleaning up alarm callback...");
  //
  //   timeoutTimer?.cancel();
  //
  //   // if (flashService != null) {
  //   //   try {
  //   //     await flashService.stop();
  //   //     print("✅ Flash service stopped");
  //   //   } catch (e) {
  //   //     print("⚠️ Error stopping flash service: $e");
  //   //   }
  //   // }
  //   //
  //   // if (vibrationService != null) {
  //   //   try {
  //   //     await vibrationService.stop();
  //   //     print("✅ Vibration service stopped");
  //   //   } catch (e) {
  //   //     print("⚠️ Error stopping vibration service: $e");
  //   //   }
  //   // }
  //
  //   // if (dismissPort != null) {
  //   //   try {
  //   //     final portName = 'alarm_dismiss_port_$id';
  //   //     IsolateNameServer.removePortNameMapping(portName);
  //   //     dismissPort.close();
  //   //     print("✅ Dismiss port cleaned up");
  //   //   } catch (e) {
  //   //     print("⚠️ Error cleaning up dismiss port: $e");
  //   //   }
  //   // }
  //
  //   print("=== ALARM CALLBACK COMPLETED ===");
  // }
}

void _sendMessageToUI(int id, String label, int pattern) {
  // Use a separate isolate/timer to avoid blocking the main callback
  Timer.periodic(const Duration(milliseconds: 100), (timer) {
    if (timer.tick > 50) { // Stop after 5 seconds
      timer.cancel();
      print("❌ Gave up sending message to UI after 5 seconds");
      return;
    }

    final uiPort = IsolateNameServer.lookupPortByName('alarm_ui_port');
    if (uiPort != null) {
      try {
        uiPort.send({'id': id, 'label': label, 'pattern': pattern});
        timer.cancel();
        print("✅ Successfully sent alarm message to UI");
      } catch (e) {
        print("❌ Error sending message to UI: $e");
      }
    } else {
      if (timer.tick % 10 == 0) { // Print every second
        print("⏳ UI port not found, retrying... (${timer.tick}/50)");
      }
    }
  });
}

class AlarmCallbackService {
  AlarmCallbackService();

  Future<void> scheduleAlarm(Alarm alarm) async {
    print("Scheduling alarm: ${alarm.id} at ${alarm.time}");
    final scheduledTime = alarm.time;

    // Cancel any existing alarm with the same ID first
    await AndroidAlarmManager.cancel(alarm.id);

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      alarm.id,
      alarmCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      params: {
        'label': alarm.label,
        'pattern': alarm.pattern,
      },
    );
    print("✅ Alarm scheduled successfully");
  }

  Future<void> cancelAlarm(int alarmId) async {
    print("Cancelling alarm: $alarmId");

    // Cancel the scheduled alarm
    await AndroidAlarmManager.cancel(alarmId);

    // Also clean up any existing dismiss port for this alarm
    final portName = 'alarm_dismiss_port_$alarmId';
    IsolateNameServer.removePortNameMapping(portName);

    print("✅ Alarm cancelled and ports cleaned up");
  }
}