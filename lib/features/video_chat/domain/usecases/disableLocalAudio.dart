import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

class DisableLocalAudioUsecase {
  final VideoChatRepository repository;

  DisableLocalAudioUsecase({required this.repository});

  Future<void> call() async{
    await repository.disableLocalAudio();
  }
}