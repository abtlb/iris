import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

class EnableLocalVideoUsecase {
  final VideoChatRepository repository;

  EnableLocalVideoUsecase({required this.repository});

  Future<void> call() async{
    await repository.enableLocalVideo();
  }
}