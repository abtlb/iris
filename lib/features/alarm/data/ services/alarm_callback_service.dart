import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/features/alarm/data/%20services/flash_service.dart';
import 'package:untitled3/features/alarm/data/%20services/vibration_service.dart';
import 'package:untitled3/main.dart';

import '../../domain/entities/alarm_entity.dart';

@pragma('vm:entry-point')
void alarmCallback(int id, Map<String, dynamic> params) async{
  var label = params['label'] as String;
  var pattern = params['pattern'] as int;

  var flashService = FlashService();
  var vibrationService = VibrationService();

  flashService.start(pattern);
  vibrationService.start(pattern);

  // Send a message to the UI isolate
  final send = IsolateNameServer.lookupPortByName('alarm_ui_port');
  send?.send(label);

  //todo remove this
  // await Future.delayed(const Duration(seconds: 10));

  final dismissPort = ReceivePort();
  const portName    = 'alarm_dismiss_port';
  IsolateNameServer.registerPortWithName(
    dismissPort.sendPort,
    portName,
  );

  final uiPort = IsolateNameServer.lookupPortByName('alarm_ui_port');
  uiPort?.send({'id': id, 'label': label});

  await dismissPort.firstWhere((msg) => msg == 'dismiss');

  await flashService.stop();
  await vibrationService.stop();
}

class AlarmCallbackService {
  AlarmCallbackService() {
    alarmTriggeredBroadcast.listen((message) {

    });
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
    final scheduledTime = alarm.time; // a DateTime in the future

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,        // exact clock time
      alarm.id,             // unique int identifier
      alarmCallback,        // the Dart callback
      exact: true,          // fire at exactly this time
      wakeup: true,         // wake device up if it’s sleeping
      allowWhileIdle: true,
      params: {
        'label': alarm.label,
        'pattern': alarm.pattern,
      },
    );
  }

  Future<void> cancelAlarm(int alarmId) async {
    await AndroidAlarmManager.cancel(alarmId);
  }

}