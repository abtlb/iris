import 'package:untitled3/features/alarm/domain/entities/flash_data.dart';
import 'package:untitled3/features/alarm/domain/entities/vibration_data.dart';
import 'package:untitled3/features/alarm/domain/entities/week_day.dart';

class Alarm {
  final int id;
  final List<WeekDay> repeatDays;
  final String label;
  final bool isEnabled;
  final DateTime time;
  final int pattern;

  Alarm({
    required this.id,
    required this.repeatDays,
    required this.label,
    required this.isEnabled,
    required this.time,
    required this.pattern,
  });

  Alarm copyWith({
    int? id,
    List<WeekDay>? repeatDays,
    String? label,
    bool? isEnabled,
    DateTime? time,
    VibrationData? vibrationData,
    FlashData? flashData,
    int? pattern
  }) {
    return Alarm(
      id: id ?? this.id,
      repeatDays: repeatDays ?? List<WeekDay>.from(this.repeatDays),
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
      pattern: pattern ?? this.pattern
    );
  }
}
