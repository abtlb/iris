import 'package:untitled3/features/alarm/domain/repositories/alarm_repository.dart';

class CancelAlarm {
  final AlarmRepository alarmRepository;

  CancelAlarm({required this.alarmRepository});

  void call(int alarmId) {
    alarmRepository.cancelAlarm(alarmId);
  }
}