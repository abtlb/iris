// sound_monitor_states.dart

import 'package:equatable/equatable.dart';
import 'package:untitled3/features/sound_detection/domain/entities/sound_detection_settings.dart';

abstract class SoundMonitorState extends Equatable {
  const SoundMonitorState();

  @override
  List<Object?> get props => [];
}

class SoundMonitorInitial extends SoundMonitorState {
  const SoundMonitorInitial();
}

class SoundMonitorLoading extends SoundMonitorState {
  const SoundMonitorLoading();
}

class SoundMonitorRunning extends SoundMonitorState {
  final double dbLevel;
  final List<String> soundEvents;
  final SoundDetectionSettings? settings;

  const SoundMonitorRunning({
    required this.dbLevel,
    required this.soundEvents,
    this.settings,
  });

  @override
  List<Object?> get props => [dbLevel, soundEvents, settings];

  SoundMonitorRunning copyWith({
    double? dbLevel,
    List<String>? soundEvents,
    SoundDetectionSettings? settings,
  }) {
    return SoundMonitorRunning(
      dbLevel: dbLevel ?? this.dbLevel,
      soundEvents: soundEvents ?? this.soundEvents,
      settings: settings ?? this.settings,
    );
  }
}

class AlarmTriggered extends SoundMonitorState {
  final String reason;

  const AlarmTriggered({required this.reason});

  @override
  List<Object?> get props => [reason];
}

class SoundMonitorError extends SoundMonitorState {
  final String message;

  const SoundMonitorError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SettingsUpdated extends SoundMonitorState {
  final SoundDetectionSettings settings;

  const SettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}