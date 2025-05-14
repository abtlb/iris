import 'package:signalr_netcore/errors.dart';
import 'package:untitled3/features/alarm/domain/entities/alarm_entity.dart';
import 'package:untitled3/features/alarm/domain/repositories/alarm_repository.dart';

class ObserveAlarmEvents {
  final AlarmRepository alarmRepository;

  ObserveAlarmEvents({required this.alarmRepository});

  Stream<Alarm> call() {
    throw NotImplementedException();
  }
}