import '../entities/alarm_entity.dart';

abstract class AlarmRepository {
  Future<void> scheduleAlarm(Alarm alarm);
  Future<void> cancelAlarm(int alarmId);
  // Stream<Alarm> onAlarmTriggered();   // emits when an alarm fires
  Future<List<Alarm>> getAllAlarms();
  Future<void> updateAlarm(Alarm alarm);
}