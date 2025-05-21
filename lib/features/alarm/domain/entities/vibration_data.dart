import 'package:untitled3/features/alarm/domain/entities/vibration_level.dart';

/// Represents vibration settings for an alarm.
class VibrationData {
  final bool hasVibration;
  final List<int>? vibrationDurations;
  final List<VibrationLevel>? vibrationLevels;

  VibrationData({
    required this.hasVibration,
    this.vibrationDurations,
    this.vibrationLevels,
  });

  /// Converts this [VibrationData] into a JSON map.
  Map<String, dynamic> toJson() => {
    'hasVibration': hasVibration,
    'vibrationDurations': vibrationDurations,
    'vibrationLevels': vibrationLevels
        ?.map((level) => level.toString().split('.').last)
        .toList(),
  };

  /// Constructs a [VibrationData] from a JSON map.
  factory VibrationData.fromJson(Map<String, dynamic> json) {
    final durations = (json['vibrationDurations'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList();
    final levels = (json['vibrationLevels'] as List<dynamic>?)
        ?.map((e) => VibrationLevel.values.firstWhere(
          (lvl) => lvl.toString().split('.').last == e as String,
    ))
        .toList();

    return VibrationData(
      hasVibration: json['hasVibration'] as bool,
      vibrationDurations: durations,
      vibrationLevels: levels,
    );
  }
}
