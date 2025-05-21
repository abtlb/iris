// alarm_trigger_state.dart
part of 'alarm_trigger_cubit.dart';

@immutable
abstract class AlarmTriggerState {}
class AlarmTriggerIdle extends AlarmTriggerState {}
class AlarmTriggerRinging extends AlarmTriggerState {
  final Alarm alarm;
  AlarmTriggerRinging({required this.alarm});
}