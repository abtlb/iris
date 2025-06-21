import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../repository/VideoChatRepository.dart';

class ConnectToVideoChatCustom {
  final VideoChatRepository repository;

  ConnectToVideoChatCustom({required this.repository});

  Future<RtcEngine> call(String channel, int uid) async{
    await repository.requestPermissions();
    RtcEngine engine = await repository.initializeSDK();
    await repository.setupLocalVideo();
    repository.setupEventHandlers();
    await repository.joinChannelCustom(channel, uid);

    return engine;
  }


}