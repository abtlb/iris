import 'package:untitled3/features/sound_detection/domain/entities/sound_detection_settings.dart';

import '../entities/classification_result.dart';

abstract class SoundRepository {
  Stream<double> getDecibelStream(); // for dB gauge
  Stream<List<ClassificationResult>> detectSoundEvents(); // identifies sound types
  Future<void> stopContinuousClassification();
  Future<bool> requestMicrophonePermission();
  Future<SoundDetectionSettings> getSettings();
  Future<void> saveSettings(SoundDetectionSettings settings);
  Future<void> showNotification(String message);
}
