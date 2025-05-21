// alarm_trigger_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:untitled3/features/alarm/domain/entities/alarm_entity.dart';

import '../../../domain/repositories/alarm_repository.dart';

part 'alarm_trigger_state.dart';

/// Listens for alarm firing events
class AlarmTriggerCubit extends Cubit<AlarmTriggerState> {
  final AlarmRepository repository;
  AlarmTriggerCubit({required this.repository}) : super(AlarmTriggerIdle()) {
    // repository.onAlarmTriggered().listen((alarm) {
    //   emit(AlarmTriggerRinging(alarm: alarm));
    // });
    throw NotImplementedException();
  }

  void clear() => emit(AlarmTriggerIdle());
}