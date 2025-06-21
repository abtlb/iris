// sound_monitor_events.dart

import 'package:equatable/equatable.dart';
import 'package:untitled3/features/sound_detection/domain/entities/sound_detection_settings.dart';

abstract class SoundMonitorEvent extends Equatable {
  const SoundMonitorEvent();

  @override
  List<Object?> get props => [];
}

class StartMonitoringEvent extends SoundMonitorEvent {
  const StartMonitoringEvent();
}

class StopMonitoringEvent extends SoundMonitorEvent {
  const StopMonitoringEvent();
}

class RestartMonitoringEvent extends SoundMonitorEvent {
  const RestartMonitoringEvent();
}

class NoiseDetectedEvent extends SoundMonitorEvent {
  final double dbLevel;

  const NoiseDetectedEvent({required this.dbLevel});

  @override
  List<Object?> get props => [dbLevel];
}

class SoundClassifiedEvent extends SoundMonitorEvent {
  final List<String> soundCategories;

  const SoundClassifiedEvent({required this.soundCategories});

  @override
  List<Object?> get props => [soundCategories];
}

class TriggerAlarmEvent extends SoundMonitorEvent {
  final String reason;

  const TriggerAlarmEvent({required this.reason});

  @override
  List<Object?> get props => [reason];
}

class DismissAlarmEvent extends SoundMonitorEvent {
  const DismissAlarmEvent();
}

class SaveSettingsEvent extends SoundMonitorEvent {
  final SoundDetectionSettings settings;

  const SaveSettingsEvent({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class LoadSettingsEvent extends SoundMonitorEvent {
  const LoadSettingsEvent();
}

class MonitoringErrorEvent extends SoundMonitorEvent {
  final String message;

  const MonitoringErrorEvent({required this.message});

  @override
  List<Object?> get props => [message];
}