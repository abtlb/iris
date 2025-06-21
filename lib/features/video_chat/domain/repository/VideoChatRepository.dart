import 'package:agora_rtc_engine/agora_rtc_engine.dart';

abstract class VideoChatRepository {
  Future<RtcEngine> initializeSDK();
  Future<void> joinChannel(String channel, int uid);
  Future<void> joinChannelCustom(String channel, int uid);
  Future<void> pushExternalVideoFrame(ExternalVideoFrame frame);
  void setupEventHandlers();
  Stream<int?> get remoteUserStream;
  Stream<int?> get localUserStream;
  Stream<bool?> get remoteUserVideoStreamMuted;
  Future<void> setupLocalVideo();
  Future<void> cleanupEngine();
  Future<void> requestPermissions();
  Stream<String> getPredictionStream();
  Future<String> getChatToken(String channelName);
  Future<void> disableLocalVideo();
  Future<void> enableLocalVideo();
  Future<void> enableLocalAudio();
  Future<void> disableLocalAudio();
  RtcEngine? getVideoEngine();
}