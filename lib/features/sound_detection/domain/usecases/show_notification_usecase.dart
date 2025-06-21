import 'package:untitled3/features/sound_detection/domain/repositories/sound_repository.dart';

class ShowNotificationUsecase {
  final SoundRepository soundRepository;

  ShowNotificationUsecase({required this.soundRepository});

  Future<void> call(String message) async {
    await soundRepository.showNotification(message);
  }
}