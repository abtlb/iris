import 'package:untitled3/features/alarm/domain/entities/alarm_entity.dart';
import 'package:untitled3/features/alarm/domain/repositories/alarm_repository.dart';

class ScheduleAlarm {
  final AlarmRepository alarmRepository;

  ScheduleAlarm({required this.alarmRepository});

  Future<void> call(Alarm alarm) async {
    await alarmRepository.scheduleAlarm(alarm);
  }
}