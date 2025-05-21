import 'dart:convert';

import 'package:untitled3/features/alarm/domain/entities/flash_data.dart';
import 'package:untitled3/features/alarm/domain/entities/vibration_data.dart';

import '../../domain/entities/alarm_entity.dart';
import '../../domain/entities/week_day.dart';

/// Data Transfer Object for persisting and retrieving Alarm data.
class AlarmModel {
  final int id;
  final bool isEnabled;
  final String label;
  final String time; // ISO8601 string
  final List<String> repeatDays;
  final int pattern;

  AlarmModel({
    required this.id,
    required this.label,
    required this.time,
    required this.repeatDays,
    required this.isEnabled,
    required this.pattern
  });

  /// Converts a domain [Alarm] to an [AlarmModel] for storage.
  factory AlarmModel.fromDomain(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      label: alarm.label,
      time: alarm.time.toIso8601String(),
      repeatDays: alarm.repeatDays.map((d) => d.name).toList(),
      isEnabled: alarm.isEnabled,
      pattern: alarm.pattern,
    );
  }

  /// Converts this model into a domain [Alarm] entity.
  Alarm toDomain() {
    return Alarm(
      id: id,
      label: label,
      time: DateTime.parse(time),
      repeatDays: repeatDays.map(WeekDayX.fromName).toList(),
      isEnabled: isEnabled,
      pattern: pattern,
    );
  }

  /// Serializes this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'time': time,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays,
      'pattern': pattern
    };
  }

  /// Constructs an [AlarmModel] from JSON.
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    final rawPattern = json['pattern'];
    print("Raw pattern: $rawPattern");
    final int pattern = (rawPattern is int && rawPattern >= 1) ? rawPattern : 1;

    return AlarmModel(
      id: json['id'] as int,
      label: json['label'] as String,
      time: json['time'] as String,

      repeatDays: List<String>.from(json['repeatDays'] as List),
      isEnabled: json['isEnabled'],
      pattern: pattern,
    );
  }
}
