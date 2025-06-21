import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

class DisableLocalVideoUsecase {
  final VideoChatRepository repository;

  DisableLocalVideoUsecase({required this.repository});

  Future<void> call() async{
    await repository.disableLocalVideo();
  }
}