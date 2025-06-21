import 'dart:async';

import 'package:untitled3/features/sound_detection/domain/repositories/sound_repository.dart';

import '../entities/classification_result.dart';
import '../entities/sound_detection_settings.dart';

class SaveSoundDetectionSettingsUsecase {
  final SoundRepository _repository;

  SaveSoundDetectionSettingsUsecase(this._repository);

  Future<void> call(SoundDetectionSettings settings) async {
    return await _repository.saveSettings(settings);
  }
}