import 'dart:async';

import 'package:untitled3/features/alarm/data/%20services/alarm_callback_service.dart';
import 'package:untitled3/features/alarm/data/%20services/alarm_notification_ds.dart';
import 'package:untitled3/features/alarm/domain/entities/alarm_entity.dart';
import 'package:untitled3/features/alarm/domain/entities/flash_data.dart';
import 'package:untitled3/features/alarm/domain/entities/vibration_data.dart';
import 'package:untitled3/features/alarm/domain/entities/week_day.dart';

import '../../domain/repositories/alarm_repository.dart';
import '../datasources/local_alarm_data_source.dart';
import '../../../../core/services/local_notification_ds.dart';
import '../models/alarm_model.dart';

/// Concrete implementation of [AlarmRepository], wiring domain alarms to
/// platform notification APIs and optional IoT light flashes.
class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmNotificationService notifications;
  final LocalAlarmDataSource localAlarmDataSource;
  final AlarmCallbackService alarmCallbackService;

  static const int _max32 = 0x7fffffff; // 2^31 - 1
  int _to32(int id) => id & _max32;

  AlarmRepositoryImpl({
    required this.notifications,
    required this.localAlarmDataSource,
    required this.alarmCallbackService,
  });

  @override
  Future<void> scheduleAlarm(Alarm alarm) async {
    alarm = alarm.copyWith(id: _to32(alarm.id));

    if (alarm.isEnabled) {
      var scheduledAlarm = await scheduleNextAlarm(alarm);
      await localAlarmDataSource.addAlarm(AlarmModel.fromDomain(scheduledAlarm));
    }
  }

  @override
  Future<void> updateAlarm(Alarm alarm) async {
    alarm = alarm.copyWith(id: _to32(alarm.id));

    await notifications.cancelAlarmNotification(alarm.id);
    await alarmCallbackService.cancelAlarm(alarm.id);
    await localAlarmDataSource.deleteAlarm(alarm.id);

    if (alarm.isEnabled) {
      var scheduledAlarm = await scheduleNextAlarm(alarm);
      await localAlarmDataSource.addAlarm(AlarmModel.fromDomain(scheduledAlarm));
    }
    else {
      await localAlarmDataSource.addAlarm(AlarmModel.fromDomain(alarm));
    }
  }

  Future<Alarm> scheduleNextAlarm(Alarm alarm) async {
    if (alarm.repeatDays.isNotEmpty) {
      var nextTime = getNearestTime(alarm.time, alarm.repeatDays);
      alarm = alarm.copyWith(time: nextTime);
      print("alarm timmeee: ${alarm.time.toString()}");
    }

    await notifications.scheduleAlarmNotification(
      id: alarm.id,
      title: alarm.label,
      body: 'Alarm for ${alarm.time.hour}:${alarm.time.minute}',
      scheduledTime: alarm.time,
    );

    // Schedule alarm callback
    await alarmCallbackService.scheduleAlarm(
        alarm);

    return alarm;
  }

  @override
  Future<void> cancelAlarm(int alarmId) async {
    alarmId = _to32(alarmId);

    await localAlarmDataSource.deleteAlarm(alarmId);
    // Cancel system notification
    await notifications.cancelAlarmNotification(alarmId);
    await alarmCallbackService.cancelAlarm(alarmId);
  }

  @override
  Future<List<Alarm>> getAllAlarms() async {
    // Load the stored AlarmModels
    final models = await localAlarmDataSource.loadAlarms();
    final now = DateTime.now();
    final List<Alarm> alarms = [];

    for (var model in models) {
      final alarm = model.toDomain();

      // If alarm is in the past, disable and reschedule date to next occurrence
      if (alarm.time.isBefore(now)) {
        // Compute next date with same clock time, at least one day ahead
        final candidate = DateTime(
          now.year,
          now.month,
          now.day,
          alarm.time.hour,
          alarm.time.minute,
        );
        final nextTime = candidate.isAfter(now)
            ? candidate
            : candidate.add(const Duration(days: 1));

        // Create a disabled Alarm with updated time
        final updated = alarm.copyWith(
          time: nextTime,
          isEnabled: false,
        );

        // Persist changes and cancel any pending notification
        await updateAlarm(updated);

        alarms.add(updated);
      } else {
        alarms.add(alarm);
      }
    }

    // sorted by time
    alarms.sort((a, b) => a.time.compareTo(b.time));

    return alarms;
  }

  DateTime getNearestTime(DateTime time, List<WeekDay> repeatDays) {
    if (repeatDays.isEmpty) return time;

    final now = DateTime.now();
    final targetHour   = time.hour;
    final targetMinute = time.minute;
    final targetSecond = time.second;

    // Build a set of integers 1–7 for fast lookup
    final daysOfWeek = repeatDays.map(_weekdayValue).toSet();

    for (int addDays = 0; addDays < 7; addDays++) {
      final candidateDate = now.add(Duration(days: addDays));
      if (!daysOfWeek.contains(candidateDate.weekday)) continue;

      // If it's today, only accept if time hasn't passed yet
      if (addDays == 0) {
        final candidateTime = DateTime(
          candidateDate.year,
          candidateDate.month,
          candidateDate.day,
          targetHour,
          targetMinute,
          targetSecond,
        );
        if (candidateTime.isAfter(now)) {
          return candidateTime;
        }
        // else skip today, look at next matching day
      } else {
        return DateTime(
          candidateDate.year,
          candidateDate.month,
          candidateDate.day,
          targetHour,
          targetMinute,
          targetSecond,
        );
      }
    }

    // Fallback: next week's first repeat day
    // (this only happens if today+0 was the only match but time passed)
    final firstDay = repeatDays.first;
    final weekday   = _weekdayValue(firstDay);

    // compute days until next occurrence of firstDay
    final daysUntil = (weekday - now.weekday + 7) % 7;
    final nextDate = now.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));

    return DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      targetHour,
      targetMinute,
      targetSecond,
    );
  }

  int _weekdayValue(WeekDay day) {
    switch (day) {
      case WeekDay.monday: return DateTime.monday;
      case WeekDay.tuesday: return DateTime.tuesday;
      case WeekDay.wednesday: return DateTime.wednesday;
      case WeekDay.thursday: return DateTime.thursday;
      case WeekDay.friday: return DateTime.friday;
      case WeekDay.saturday: return DateTime.saturday;
      case WeekDay.sunday: return DateTime.sunday;
    }
  }

}
