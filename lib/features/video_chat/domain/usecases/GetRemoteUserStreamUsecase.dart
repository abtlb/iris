import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

class GetRemoteUserStreamUsecase {
  final VideoChatRepository repository;

  GetRemoteUserStreamUsecase({required this.repository});

  Stream<int?> call() {
    // This returns a stream of remote user IDs (or null when no remote user is present)
    print("remote user usecase called");
    return repository.remoteUserStream;
  }
}