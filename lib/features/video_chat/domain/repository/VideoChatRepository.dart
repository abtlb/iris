import 'package:agora_rtc_engine/agora_rtc_engine.dart';

abstract class VideoChatRepository {
  Future<RtcEngine> initializeSDK();
  Future<void> joinChannel(String channel, int uid);
  void setupEventHandlers();
  Stream<int?> get remoteUserStream;
  Stream<int?> get localUserStream;
  Future<void> setupLocalVideo();
  Future<void> cleanupEngine();
  Future<void> requestPermissions();
  Stream<String> getPredictionStream();
  Future<String> getChatToken(String channelName);
}