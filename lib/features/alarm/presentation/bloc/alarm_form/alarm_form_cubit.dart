import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/alarm_entity.dart';
import '../../../domain/entities/flash_data.dart';
import '../../../domain/entities/vibration_data.dart';
import '../../../domain/entities/week_day.dart';
import 'alarm_form_state.dart';

class AlarmFormCubit extends Cubit<AlarmFormState> {
  AlarmFormCubit({Alarm? initialAlarm})
      : super(
    AlarmFormState(
      alarm: initialAlarm ??
          Alarm(
            id: DateTime.now().millisecondsSinceEpoch,
            label: '',
            time: DateTime.now(),
            repeatDays: List<WeekDay>.empty(),
            isEnabled: true,
            pattern: 1,
          ),
      isValid: initialAlarm != null
          ? _validate(initialAlarm)
          : false,
    ),
  ){print(initialAlarm?.time.toString());}

  /// Update the alarm’s time and re-validate.
  void updateTime(DateTime newTime) {
    print(newTime.toString());
    var newAlarm = state.alarm.copyWith(time: newTime);
    _emit(newAlarm);
  }

  /// Update the repeat days list and re-validate.
  void updateRepeat(List<WeekDay> newDays) {
    //state.alarm.repeatDays = newDays.map((d) => WeekDayX.fromShortName(d)).toList();
    var newAlarm = state.alarm.copyWith(repeatDays: newDays);
    _emit(newAlarm);
  }

  void toggleEnabled() {
    var newAlarm = state.alarm.copyWith(isEnabled: !state.alarm.isEnabled);
    _emit(newAlarm);
  }

  void updateLabel(String newLabel) {
    var newAlarm = state.alarm.copyWith(label: newLabel);
    _emit(newAlarm);
  }
  
  void updatePattern(int pattern) {
    var newAlarm = state.alarm.copyWith(pattern: pattern);
    _emit(newAlarm);
  }

  void _emit(Alarm updatedAlarm) {
    updatedAlarm = fix(updatedAlarm);
    final valid = _validate(updatedAlarm);
    print("Alarm settings: \n "
        "Is enabled: ${updatedAlarm.isEnabled} \n"
        "Repeat days: ${updatedAlarm.repeatDays} \n"
        "Time: ${updatedAlarm.time}\n"
        "Label: ${updatedAlarm.label}\n"
        "Pattern: ${updatedAlarm.pattern}\n");
    emit(state.copyWith(alarm: updatedAlarm, isValid: valid));
  }

  Alarm fix(Alarm alarm) {
    if (alarm.time.isBefore(DateTime.now())) {
      alarm = alarm.copyWith(time: alarm.time.add(const Duration(days: 1)));
    }
    return alarm;
  }

  static bool _validate(Alarm alarm) {
    return alarm.time.isAfter(DateTime.now());
  }
}
