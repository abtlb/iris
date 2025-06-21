import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

class EnableLocalAudioUsecase {
  final VideoChatRepository repository;

  EnableLocalAudioUsecase({required this.repository});

  Future<void> call() async{
    await repository.enableLocalAudio();
  }
}