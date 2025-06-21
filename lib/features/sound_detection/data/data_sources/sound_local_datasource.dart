import 'package:untitled3/features/sound_detection/domain/entities/sound_detection_settings.dart';

abstract class SoundLocalDataSource {
  Stream<double> decibelStream();
  Future<void> saveSettings(SoundDetectionSettings settings);
  Future<SoundDetectionSettings> getSettings();
}
