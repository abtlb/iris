import 'dart:async';

import 'package:untitled3/features/sound_detection/domain/repositories/sound_repository.dart';

import '../entities/classification_result.dart';
import '../entities/sound_detection_settings.dart';

class GetSoundDetectionSettingsUseCase {
  final SoundRepository _repository;

  GetSoundDetectionSettingsUseCase(this._repository);

  Future<SoundDetectionSettings> call() async {
    return await _repository.getSettings();
  }
}