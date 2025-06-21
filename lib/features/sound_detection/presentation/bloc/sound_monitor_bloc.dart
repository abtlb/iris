import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/features/sound_detection/domain/entities/classification_result.dart';
import 'package:untitled3/features/sound_detection/domain/entities/sound_detection_settings.dart';
import 'package:untitled3/features/sound_detection/domain/usecases/monitor_sound.dart';
import 'package:untitled3/features/sound_detection/domain/usecases/show_notification_usecase.dart';
import 'package:untitled3/features/sound_detection/domain/usecases/start_sound_classification_use_case.dart';
import 'package:untitled3/features/sound_detection/domain/usecases/stop_sound_classification_use_case.dart';
import '../../domain/usecases/get_sound_detection_settings.dart';
import '../../domain/usecases/save_sound_detection_settings.dart';
import 'sound_monitor_event.dart';
import 'sound_monitor_states.dart';

class SoundMonitorBloc extends Bloc<SoundMonitorEvent, SoundMonitorState> {
  final MonitorSoundUsecase monitorNoise;
  final StartSoundClassificationUseCase startClassification;
  final StopSoundClassificationUseCase stopClassification;
  final GetSoundDetectionSettingsUseCase getSettingsUsecase;
  final SaveSoundDetectionSettingsUsecase saveSettingsUsecase;
  final ShowNotificationUsecase showNotificationUsecase;

  StreamSubscription<double>? _noiseSub;
  StreamSubscription<List<ClassificationResult>>? _classSub;
  SoundDetectionSettings? _settings;

  double _dbLevel = 0.0;
  List<String> _soundCategories = [];
  bool _alarmTriggered = false;
  bool _isMonitoring = false;

  Timer? _clearEventsTimer;

  SoundMonitorBloc({
    required this.monitorNoise,
    required this.startClassification,
    required this.stopClassification,
    required this.getSettingsUsecase,
    required this.saveSettingsUsecase,
    required this.showNotificationUsecase
  }) : super(const SoundMonitorInitial()) {
    on<StartMonitoringEvent>(_onStartMonitoring);
    on<StopMonitoringEvent>(_onStopMonitoring);
    on<RestartMonitoringEvent>(_onRestartMonitoring);
    on<NoiseDetectedEvent>(_onNoiseDetected);
    on<SoundClassifiedEvent>(_onSoundClassified);
    on<TriggerAlarmEvent>(_onTriggerAlarm);
    on<DismissAlarmEvent>(_onDismissAlarm);
    on<SaveSettingsEvent>(_onSaveSettings);
    on<LoadSettingsEvent>(_onLoadSettings);
    on<MonitoringErrorEvent>(_onMonitoringError);
  }

  Future<void> _onStartMonitoring(
      StartMonitoringEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    if (_isMonitoring) {
      print('⚠️ Already monitoring, skipping start');
      return;
    }

    emit(const SoundMonitorLoading());

    try {
      _settings = await getSettingsUsecase();

      await _startNoise();
      await _startClassification();

      _isMonitoring = true;
      print('✅ Monitoring started successfully');

      emit(SoundMonitorRunning(
        dbLevel: _dbLevel,
        soundEvents: _soundCategories,
        settings: _settings,
      ));
    } catch (e) {
      print('❌ Failed to start monitoring: $e');
      add(MonitoringErrorEvent(message: 'Failed to start monitoring: $e'));
      add(const StopMonitoringEvent()); // Clean up on error
    }
  }

  Future<void> _onStopMonitoring(
      StopMonitoringEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    if (!_isMonitoring && _noiseSub == null && _classSub == null) {
      print('⚠️ Already stopped, skipping');
      return;
    }

    print('🛑 Stopping monitoring...');
    _isMonitoring = false;
    _alarmTriggered = false;

    try {
      // Cancel subscriptions with timeout to prevent hanging
      await Future.wait([
        _cancelWithTimeout(_noiseSub?.cancel(), 'noise subscription'),
        _cancelWithTimeout(_classSub?.cancel(), 'classification subscription'),
      ]);

      _noiseSub = null;
      _classSub = null;

      // Stop the classification use case
      try {
        await stopClassification();
      } catch (e) {
        print('⚠️ Error stopping classification use case: $e');
      }

      // Reset state
      _dbLevel = 0.0;
      _soundCategories = [];

      emit(const SoundMonitorInitial());
      print('✅ Monitoring stopped successfully');
    } catch (e) {
      print('❌ Error during stop monitoring: $e');
      add(MonitoringErrorEvent(message: 'Error stopping monitoring: $e'));
    }
  }

  Future<void> _onRestartMonitoring(
      RestartMonitoringEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    print('🔄 Restarting monitoring...');
    add(const StopMonitoringEvent());
    await Future.delayed(const Duration(milliseconds: 500)); // Brief pause
    add(const StartMonitoringEvent());
  }

  Future<void> _onNoiseDetected(
      NoiseDetectedEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    if (!_isMonitoring || _alarmTriggered) return;

    if (event.dbLevel > _settings!.dbThreshold && _settings!.isLoudNoiseEnabled) {
      add(TriggerAlarmEvent(
        reason: 'Noise level exceeded ${_settings!.dbThreshold}db: ${event.dbLevel} db!',
      ));
      return;
    }

    _dbLevel = event.dbLevel;

    if (state is SoundMonitorRunning) {
      emit((state as SoundMonitorRunning).copyWith(
        dbLevel: _dbLevel,
      ));
    }
  }

  Future<void> _onSoundClassified(
      SoundClassifiedEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    if (!_isMonitoring || _alarmTriggered) return;

    // Check if any detected sound is in the triggering sounds list
    for (var category in event.soundCategories) {
      print("sound type $category");
      if (_settings!.triggeringSounds.contains(category)) {
        add(TriggerAlarmEvent(reason: 'Sound detected: $category'));
        return; // Exit early if alarm triggered
      }
    }

    _soundCategories = event.soundCategories;

    if (state is SoundMonitorRunning) {
      emit((state as SoundMonitorRunning).copyWith(
        soundEvents: _soundCategories,
      ));
      _soundCategories = [];
      _clearEventsTimer?.cancel();
      _clearEventsTimer = Timer(const Duration(seconds: 1), () {
        add(const SoundClassifiedEvent(soundCategories: []));
      });
    }
  }

  Future<void> _onTriggerAlarm(
      TriggerAlarmEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    if (_alarmTriggered) return; // Prevent duplicate alarms

    _alarmTriggered = true;
    add(const StopMonitoringEvent());
    emit(AlarmTriggered(reason: event.reason));
    await showNotificationUsecase.call(event.reason);
  }

  Future<void> _onDismissAlarm(
      DismissAlarmEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    _alarmTriggered = false;
    add(const StopMonitoringEvent());
    print('✅ Alarm dismissed');
  }

  Future<void> _onSaveSettings(
      SaveSettingsEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    try {
      await saveSettingsUsecase(event.settings);
      _settings = event.settings;
      emit(SettingsUpdated(settings: event.settings));
    } catch (e) {
      print('❌ Error saving settings: $e');
      add(MonitoringErrorEvent(message: 'Failed to save settings: $e'));
    }
  }

  Future<void> _onLoadSettings(
      LoadSettingsEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    try {
      _settings = await getSettingsUsecase();
      emit(SettingsUpdated(settings: _settings!));
    } catch (e) {
      print('❌ Error loading settings: $e');
      add(MonitoringErrorEvent(message: 'Failed to load settings: $e'));
    }
  }

  Future<void> _onMonitoringError(
      MonitoringErrorEvent event,
      Emitter<SoundMonitorState> emit,
      ) async {
    emit(SoundMonitorError(message: event.message));
  }

  Future<void> _startNoise() async {
    if (_noiseSub != null) {
      print('⚠️ Noise subscription already exists, cancelling first');
      await _noiseSub?.cancel();
      _noiseSub = null;
    }

    try {
      _noiseSub = monitorNoise().listen(
            (db) async {
          add(NoiseDetectedEvent(dbLevel: db));
        },
        onError: (e) {
          print('❌ Noise monitoring error: $e');
          add(MonitoringErrorEvent(message: 'Noise monitoring error: $e'));
        },
        cancelOnError: true, // Auto-cancel on error
      );
    } catch (e) {
      print('❌ Failed to start noise monitoring: $e');
      throw e;
    }
  }

  Future<void> _startClassification() async {
    if (_classSub != null) {
      print('⚠️ Classification subscription already exists, cancelling first');
      await _classSub?.cancel();
      _classSub = null;
    }

    try {
      _classSub = startClassification().listen(
            (classes) async {
          final categories = classes.map((c) => c.category).toList();
          add(SoundClassifiedEvent(soundCategories: categories));
        },
        onError: (e) {
          print('❌ Classification error: $e');
          add(MonitoringErrorEvent(message: 'Classification error: $e'));
        },
        cancelOnError: true, // Auto-cancel on error
      );
    } catch (e) {
      print('❌ Failed to start classification: $e');
      throw e;
    }
  }

  // Helper method to cancel subscriptions with timeout
  Future<void> _cancelWithTimeout(Future<void>? cancelFuture, String name) async {
    if (cancelFuture == null) return;

    try {
      await cancelFuture.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('⚠️ Timeout cancelling $name');
        },
      );
    } catch (e) {
      print('❌ Error cancelling $name: $e');
    }
  }

  @override
  Future<void> close() async {
    print('🔚 Closing SoundMonitorBloc...');
    add(const StopMonitoringEvent());
    await Future.delayed(const Duration(milliseconds: 100)); // Allow stop to process
    return super.close();
  }
}