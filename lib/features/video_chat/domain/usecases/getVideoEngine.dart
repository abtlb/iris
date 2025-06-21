import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

class GetVideoEngine {
  final VideoChatRepository repository;

  GetVideoEngine({required this.repository});

  RtcEngine? call() {
    return repository.getVideoEngine();
  }

}