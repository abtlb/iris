import 'package:equatable/equatable.dart';
import 'package:untitled3/features/alarm/domain/entities/flash_data.dart';
import 'package:untitled3/features/alarm/domain/entities/vibration_data.dart';
import 'package:untitled3/features/alarm/domain/entities/week_day.dart';

import '../../../domain/entities/alarm_entity.dart';

/// Holds the current form’s Alarm draft and its validation status.
class AlarmFormState extends Equatable {
  final Alarm alarm;
  final bool isValid;

  const AlarmFormState({
    required this.alarm,
    required this.isValid,
  });

  AlarmFormState copyWith({
    Alarm? alarm,
    bool? isValid,
  }) {
    return AlarmFormState(
      alarm: alarm ?? this.alarm,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [alarm, isValid];
}