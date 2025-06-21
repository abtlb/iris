// // sound_monitor_cubit.dart
//
// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:untitled3/features/sound_detection/domain/entities/classification_result.dart';
// import 'package:untitled3/features/sound_detection/domain/entities/sound_detection_settings.dart';
// import 'package:untitled3/features/sound_detection/domain/usecases/monitor_sound.dart';
// import 'package:untitled3/features/sound_detection/domain/usecases/start_sound_classification_use_case.dart';
// import 'package:untitled3/features/sound_detection/domain/usecases/stop_sound_classification_use_case.dart';
// import '../../domain/usecases/get_sound_detection_settings.dart';
// import '../../domain/usecases/save_sound_detection_settings.dart';
// import 'sound_monitor_states.dart';
//
// class SoundMonitorCubit extends Cubit<SoundMonitorState> {
//   final MonitorSoundUsecase monitorNoise;
//   final StartSoundClassificationUseCase startClassification;
//   final StopSoundClassificationUseCase stopClassification;
//   final GetSoundDetectionSettingsUseCase getSettingsUsecase;
//   final SaveSoundDetectionSettingsUsecase saveSettingsUsecase;
//
//   StreamSubscription<double>? _noiseSub;
//   StreamSubscription<List<ClassificationResult>>? _classSub;
//   SoundDetectionSettings? _settings;
//
//   double _dbLevel = 0.0;
//   List<ClassificationResult> _classes = [];
//   bool alarmTriggered = false;
//   bool _isMonitoring = false; // ✅ Track monitoring state
//
//   SoundMonitorCubit({
//     required this.monitorNoise,
//     required this.startClassification,
//     required this.stopClassification,
//     required this.getSettingsUsecase,
//     required this.saveSettingsUsecase,
//   }) : super(SoundMonitorInitial());
//
//   /// Kick off both noise & classification streams
//   Future<void> startMonitoring() async {
//     if (_isMonitoring) {
//       print('⚠️ Already monitoring, skipping start');
//       return;
//     }
//
//     try {
//       _settings = await getSettingsUsecase();
//       emit(UpdateSettings(settings: _settings!));
//
//       await _startNoise();
//       await _startClassification();
//
//       _isMonitoring = true;
//       print('✅ Monitoring started successfully');
//     } catch (e) {
//       print('❌ Failed to start monitoring: $e');
//       emit(SoundMonitorError(message: 'Failed to start monitoring: $e'));
//       await stopMonitoring(); // Clean up on error
//     }
//   }
//
//   Future<void> _startNoise() async {
//     if (_noiseSub != null) {
//       print('⚠️ Noise subscription already exists, cancelling first');
//       await _noiseSub?.cancel();
//       _noiseSub = null;
//     }
//
//     try {
//       _noiseSub = monitorNoise().listen(
//             (db) async {
//           if (!_isMonitoring || alarmTriggered) return;
//
//           if (db > _settings!.dbThreshold) {
//             await triggerAlarm('Noise level exceeded ${_settings!.dbThreshold}db: $db db!');
//             return;
//           }
//
//           _dbLevel = db;
//
//           _emitRunning();
//         },
//         onError: (e) {
//           print('❌ Noise monitoring error: $e');
//           emit(SoundMonitorError(message: 'Noise monitoring error: $e'));
//         },
//         cancelOnError: true, // ✅ Auto-cancel on error
//       );
//     } catch (e) {
//       print('❌ Failed to start noise monitoring: $e');
//       throw e;
//     }
//   }
//
//   Future<void> _startClassification() async {
//     if (_classSub != null) {
//       print('⚠️ Classification subscription already exists, cancelling first');
//       await _classSub?.cancel();
//       _classSub = null;
//     }
//
//     try {
//       _classSub = startClassification().listen(
//             (classes) async {
//           if (!_isMonitoring || alarmTriggered) return;
//
//           for (var c in classes) {
//             if (_settings!.triggeringSounds.contains(c.category)) {
//               await triggerAlarm('Sound detected: ${c.category}');
//               return; // Exit early if alarm triggered
//             }
//           }
//
//           _classes = classes;
//           _emitRunning();
//         },
//         onError: (e) {
//           print('❌ Classification error: $e');
//           emit(SoundMonitorError(message: 'Classification error: $e'));
//         },
//         cancelOnError: true, // ✅ Auto-cancel on error
//       );
//     } catch (e) {
//       print('❌ Failed to start classification: $e');
//       throw e;
//     }
//   }
//
//   void _emitRunning() {
//     if (!_isMonitoring) return;
//
//     emit(SoundMonitorRunning(
//       dbLevel: _dbLevel,
//       soundEvents: _classes.map((c) => c.category).toList(),
//     ));
//   }
//
//   Future<void> triggerAlarm(String reason) async {
//     if (alarmTriggered) return; // Prevent duplicate alarms
//
//     alarmTriggered = true;
//     await stopMonitoring();
//     print('🚨 Alarm triggered: $reason');
//     emit(AlarmTriggered(reason: reason));
//   }
//
//   Future<void> dismissAlarm() async {
//     alarmTriggered = false;
//     await startMonitoring();
//     print('✅ Alarm dismissed');
//     _emitRunning();
//   }
//
//   /// Cancel both streams and emit initial state
//   Future<void> stopMonitoring() async {
//     if (!_isMonitoring && _noiseSub == null && _classSub == null) {
//       print('⚠️ Already stopped, skipping');
//       return;
//     }
//
//     print('🛑 Stopping monitoring...');
//     _isMonitoring = false;
//     alarmTriggered = false;
//
//     try {
//       // Cancel subscriptions with timeout to prevent hanging
//       await Future.wait([
//         _cancelWithTimeout(_noiseSub?.cancel(), 'noise subscription'),
//         _cancelWithTimeout(_classSub?.cancel(), 'classification subscription'),
//       ]);
//
//       _noiseSub = null;
//       _classSub = null;
//
//       // Stop the classification use case
//       try {
//         await stopClassification();
//       } catch (e) {
//         print('⚠️ Error stopping classification use case: $e');
//       }
//
//       // Reset state
//       _dbLevel = 0.0;
//       _classes = [];
//
//       emit(SoundMonitorInitial());
//       print('✅ Monitoring stopped successfully');
//     } catch (e) {
//       print('❌ Error during stop monitoring: $e');
//       emit(SoundMonitorError(message: 'Error stopping monitoring: $e'));
//     }
//   }
//
//   // ✅ Helper method to cancel subscriptions with timeout
//   Future<void> _cancelWithTimeout(Future<void>? cancelFuture, String name) async {
//     if (cancelFuture == null) return;
//
//     try {
//       await cancelFuture.timeout(
//         Duration(seconds: 3),
//         onTimeout: () {
//           print('⚠️ Timeout cancelling $name');
//         },
//       );
//     } catch (e) {
//       print('❌ Error cancelling $name: $e');
//     }
//   }
//
//   Future<void> saveSettings(SoundDetectionSettings settings) async {
//     try {
//       await saveSettingsUsecase(settings);
//       _settings = settings;
//       emit(UpdateSettings(settings: settings));
//     } catch (e) {
//       print('❌ Error saving settings: $e');
//       emit(SoundMonitorError(message: 'Failed to save settings: $e'));
//     }
//   }
//
//   // ✅ Add method to restart monitoring (useful for error recovery)
//   Future<void> restartMonitoring() async {
//     print('🔄 Restarting monitoring...');
//     await stopMonitoring();
//     await Future.delayed(Duration(milliseconds: 500)); // Brief pause
//     await startMonitoring();
//   }
//
//   @override
//   Future<void> close() async {
//     print('🔚 Closing SoundMonitorCubit...');
//     await stopMonitoring();
//     return super.close();
//   }
// }