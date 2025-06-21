// infrastructure/repositories/sound_recognition_repository_impl.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:untitled3/core/services/local_notification_ds.dart';
import 'package:untitled3/features/sound_detection/data/data_sources/sound_local_datasource.dart';
import 'package:untitled3/features/sound_detection/domain/entities/sound_detection_settings.dart';
import 'package:untitled3/features/sound_detection/domain/repositories/sound_repository.dart';

import '../../domain/entities/classification_result.dart';
import '../models/sound_classifier_model.dart';

class SoundRepositoryImpl implements SoundRepository {
  static const int _sampleRate = 16000;
  static const int _bytesPerSample = 2;
  static const Duration _maxRecordingDuration = Duration(minutes: 30);
  static const Duration _restartDelay = Duration(milliseconds: 500);

  final SoundClassifier soundClassifier;
  final SoundLocalDataSource localDataSource;
  final LocalNotificationDataSource localNotificationDataSource;

  AudioRecorder? _audioRecorder;
  StreamController<List<ClassificationResult>>? _classificationController;
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  Timer? _maxDurationTimer;
  Timer? _restartTimer;

  bool _isRecording = false;
  bool _isDisposed = false;
  bool _shouldRestart = false;
  List<int> _audioBuffer = [];
  int _restartAttempts = 0;
  static const int _maxRestartAttempts = 3;

  int get _expectedChunkSize => SoundClassifier.requiredInputSamples * _bytesPerSample;

  SoundRepositoryImpl(this.localDataSource, this.soundClassifier, this.localNotificationDataSource);

  @override
  Future<void> showNotification(String message) async {
    await localNotificationDataSource.show(id: 100000, title: "Sound detection triggered", body: message);
  }

  @override
  Stream<List<ClassificationResult>> detectSoundEvents() {
    if (_isDisposed) {
      throw StateError('Repository has been disposed');
    }

    // Return existing stream if available
    if (_classificationController != null && !_classificationController!.isClosed) {
      return _classificationController!.stream;
    }

    _initializeStream();
    return _classificationController!.stream;
  }

  void _initializeStream() {
    _classificationController?.close();
    _classificationController = StreamController<List<ClassificationResult>>.broadcast(
      onListen: () => _handleStreamListen(),
      onCancel: () => _handleStreamCancel(),
    );
  }

  void _handleStreamListen() {
    print('Stream listener added - starting classification');
    _startClassificationSafely();
  }

  void _handleStreamCancel() {
    print('All stream listeners cancelled - stopping classification');
    _shouldRestart = false;
    _stopRecordingImmediately();
  }

  void _startClassificationSafely() async {
    if (_isRecording || _isDisposed) return;

    try {
      await _ensurePermissions();
      await _loadModelSafely();
      await _startRecording();
    } catch (e) {
      print('Failed to start classification: $e');
      _addError('Classification failed to start: $e');
      _scheduleRestart();
    }
  }

  Future<void> _ensurePermissions() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final requested = await Permission.microphone.request();
      if (!requested.isGranted) {
        throw Exception('Microphone permission required');
      }
    }
  }

  Future<void> _loadModelSafely() async {
    try {
      await soundClassifier.loadModel();
      _logModelInfo();
    } catch (e) {
      throw Exception('Model loading failed: $e');
    }
  }

  void _logModelInfo() {
    final samples = SoundClassifier.requiredInputSamples;
    final bytes = _expectedChunkSize;
    final duration = samples / _sampleRate;

    print('Audio Model Configuration:');
    print('  Samples: $samples');
    print('  Bytes: $bytes');
    print('  Duration: ${duration.toStringAsFixed(3)}s');
    print('  Sample Rate: $_sampleRate Hz');
  }

  Future<void> _startRecording() async {
    await _stopRecordingCleanly(); // Ensure clean state

    _audioRecorder = AudioRecorder();
    _isRecording = true;
    _audioBuffer.clear();

    try {
      final stream = await _audioRecorder!.startStream(
        RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
          autoGain: false,
          echoCancel: false,
          noiseSuppress: false,
        ),
      );

      _audioStreamSubscription = stream.listen(
        _processAudioData,
        onError: _handleAudioError,
        onDone: _handleAudioDone,
        cancelOnError: false, // Don't auto-cancel on error
      );

      _setMaxDurationTimer();
      _restartAttempts = 0; // Reset restart attempts on successful start
      print('Audio recording started successfully');

    } catch (e) {
      _isRecording = false;
      throw Exception('Failed to start audio stream: $e');
    }
  }

  void _processAudioData(Uint8List data) {
    if (!_isRecording || _isDisposed) return;

    try {
      _audioBuffer.addAll(data);

      while (_audioBuffer.length >= _expectedChunkSize) {
        final chunk = Uint8List.fromList(_audioBuffer.sublist(0, _expectedChunkSize));
        _audioBuffer.removeRange(0, _expectedChunkSize);

        _classifyChunk(chunk);
      }
    } catch (e) {
      print('Audio processing error: $e');
      _handleAudioError(e);
    }
  }

  void _classifyChunk(Uint8List chunk) async {
    if (_isDisposed) return;

    try {
      final rawResults = await soundClassifier.runInference(chunk);
      if (_isDisposed || _classificationController == null) return;

      final results = rawResults
          .map((r) => ClassificationResult(
        category: r['category'] as String,
        confidence: (r['confidence'] as num).toDouble(),
      ))
          .where((r) => r.confidence > 0.15)
          .toList();

      if (results.isNotEmpty && !_classificationController!.isClosed) {
        _classificationController!.add(results);
      }
    } catch (e) {
      print('Classification error: $e');
      // Don't restart on classification errors, just log them
    }
  }

  void _handleAudioError(dynamic error) {
    print('Audio stream error: $error');
    _addError('Audio error: $error');
    _scheduleRestart();
  }

  void _handleAudioDone() {
    print('Audio stream completed unexpectedly');
    _scheduleRestart();
  }

  void _setMaxDurationTimer() {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = Timer(_maxRecordingDuration, () {
      print('Maximum recording duration reached - restarting');
      _scheduleRestart();
    });
  }

  void _scheduleRestart() {
    if (_isDisposed || !_shouldRestart) return;
    if (_restartAttempts >= _maxRestartAttempts) {
      print('Maximum restart attempts reached - stopping');
      _addError('Audio system became unstable - stopping detection');
      return;
    }

    _restartAttempts++;
    print('Scheduling restart attempt $_restartAttempts/$_maxRestartAttempts');

    _stopRecordingImmediately();

    _restartTimer?.cancel();
    _restartTimer = Timer(_restartDelay, () {
      if (!_isDisposed && _shouldRestart) {
        _startClassificationSafely();
      }
    });
  }

  void _stopRecordingImmediately() {
    _isRecording = false;
    _audioBuffer.clear();

    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;

    // Cancel subscription first (most important for preventing crashes)
    _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;

    // Then stop recorder with error handling
    _stopRecorderSafely();
  }

  void _stopRecorderSafely() async {
    if (_audioRecorder == null) return;

    try {
      // Add a small delay to let the subscription cancel fully
      await Future.delayed(Duration(milliseconds: 100));

      if (await _audioRecorder!.isRecording()) {
        await _audioRecorder!.stop();
      }
    } catch (e) {
      print('Error stopping recorder (non-critical): $e');
    } finally {
      try {
        _audioRecorder?.dispose();
      } catch (e) {
        print('Error disposing recorder (non-critical): $e');
      }
      _audioRecorder = null;
    }
  }

  Future<void> _stopRecordingCleanly() async {
    _shouldRestart = false;
    _restartTimer?.cancel();
    _restartTimer = null;

    _stopRecordingImmediately();

    // Wait a bit longer for clean shutdown
    await Future.delayed(Duration(milliseconds: 200));
  }

  @override
  Future<void> stopContinuousClassification() async {
    print('Stopping continuous classification');
    await _stopRecordingCleanly();

    try {
      if (_classificationController != null && !_classificationController!.isClosed) {
        await _classificationController!.close();
      }
    } catch (e) {
      print('Error closing controller: $e');
    } finally {
      _classificationController = null;
    }
  }

  void _addError(String error) {
    try {
      if (!_isDisposed &&
          _classificationController != null &&
          !_classificationController!.isClosed) {
        _classificationController!.addError(error);
      }
    } catch (e) {
      print('Failed to add error to stream: $e');
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    print('Disposing SoundRepositoryImpl');
    _isDisposed = true;
    _shouldRestart = false;

    await _stopRecordingCleanly();

    try {
      _classificationController?.close();
      _classificationController = null;
    } catch (e) {
      print('Error disposing controller: $e');
    }

    try {
      soundClassifier.dispose();
    } catch (e) {
      print('Error disposing classifier: $e');
    }
  }

  @override
  Stream<double> getDecibelStream() {
    if (_isDisposed) throw StateError('Repository disposed');
    return localDataSource.decibelStream();
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  @override
  Future<SoundDetectionSettings> getSettings() async {
    if (_isDisposed) throw StateError('Repository disposed');
    return await localDataSource.getSettings();
  }

  @override
  Future<void> saveSettings(SoundDetectionSettings settings) async {
    if (_isDisposed) throw StateError('Repository disposed');
    await localDataSource.saveSettings(settings);
  }

  // Status getters
  bool get isRecording => _isRecording;
  bool get isDisposed => _isDisposed;
  int get bufferSize => _audioBuffer.length;
  int get restartAttempts => _restartAttempts;
}