import '../repository/VideoChatRepository.dart';

class GetPredictionStreamUsecase {
  final VideoChatRepository videoChatRepository;

  GetPredictionStreamUsecase({required this.videoChatRepository});

  Stream<String> call() {
    return videoChatRepository.getPredictionStream();
  }
}