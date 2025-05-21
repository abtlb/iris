
part of 'alarm_list_cubit.dart';

@immutable
abstract class AlarmListState {}
class AlarmListInitial extends AlarmListState {}
class AlarmListLoading extends AlarmListState {}
class AlarmListLoaded extends AlarmListState {
  final List<Alarm> alarms;
  AlarmListLoaded({required this.alarms});
}
class AlarmListError extends AlarmListState {
  final String message;
  AlarmListError({required this.message});
}