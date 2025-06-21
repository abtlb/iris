import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

class GetVideoMuteStreamUsecase {
  final VideoChatRepository repository;

  GetVideoMuteStreamUsecase({required this.repository});

  Stream<bool?> call() {
    // This returns a stream of remote user IDs (or null when no remote user is present)
    return repository.remoteUserVideoStreamMuted;
  }
}