import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:untitled3/core/usecases/usecase.dart';
import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

class ConnectToVideoChatUsecase{
  final VideoChatRepository repository;

  ConnectToVideoChatUsecase({required this.repository});

  Future<RtcEngine> call(String channel, int uid) async{
    await repository.requestPermissions();
    RtcEngine engine = await repository.initializeSDK();
    await repository.setupLocalVideo();
    repository.setupEventHandlers();
    await repository.joinChannel(channel, uid);
    await repository.disableLocalVideo();//disable local video sharing by default

    return engine;
  }
}