import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noise_meter/noise_meter.dart'; // For decibel
import 'package:untitled3/features/sound_detection/domain/entities/sound_detection_settings.dart';
import 'sound_local_datasource.dart';

class SoundLocalDataSourceImpl implements SoundLocalDataSource {
  static const _key = 'sound_detection_settings';

  final NoiseMeter _noiseMeter = NoiseMeter();

  @override
  Stream<double> decibelStream() async* {
    await for (var noiseReading in _noiseMeter.noise) {
      yield noiseReading.meanDecibel;
    }
  }

  @override
  Future<SoundDetectionSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_key);

    if (settingsJson == null) {
      // Return default settings if none are saved
      return SoundDetectionSettings(
        dbThreshold: 100.0, // Default threshold
        triggeringSounds: [], // Empty list by default
        isLoudNoiseEnabled: false,
      );
    }

    try {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return SoundDetectionSettings.fromJson(settingsMap);
    } catch (e) {
      // Return default settings if parsing fails
      return SoundDetectionSettings(
        dbThreshold: 100.0,
        triggeringSounds: [],
        isLoudNoiseEnabled: false,
      );
    }
  }

  @override
  Future<void> saveSettings(SoundDetectionSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toJson());
    await prefs.setString(_key, settingsJson);
  }
}