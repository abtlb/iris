import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:untitled3/features/video_chat/data/data_sources/AgoraService.dart';
import 'package:untitled3/features/video_chat/data/others/frame_observer.dart';
import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraVideoChatRepository implements VideoChatRepository {
  RtcEngine? _engine;
  MediaEngine? _mediaEngine;
  final _remoteUserStreamController = BehaviorSubject<int?>();
  final _localUserStreamController = BehaviorSubject<int?>();
  final _remoteUserVideoStreamMuted = BehaviorSubject<bool?>();
  final AgoraService agoraService;
  final FrameObserver frameObserver;

  AgoraVideoChatRepository({required this.agoraService, required this.frameObserver});

  @override
  Stream<int?> get remoteUserStream => _remoteUserStreamController.stream;

  @override
  Stream<int?> get localUserStream => _localUserStreamController.stream;

  @override
  Stream<bool?> get remoteUserVideoStreamMuted => _remoteUserVideoStreamMuted.stream;

  @override
  Future<RtcEngine> initializeSDK() async{
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: "550b081e687947dd9d793b39b7683759",
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _mediaEngine = _engine?.getMediaEngine();
    _mediaEngine!.registerVideoFrameObserver(VideoFrameObserver(onCaptureVideoFrame: frameObserver.receiveFrame));

    return _engine!;
  }

  @override
  Future<void> joinChannel(String channel, int   uid) async{
    String token = await getChatToken(channel);
    await _engine!.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true, // Automatically subscribe to all video streams
        autoSubscribeAudio: true, // Automatically subscribe to all audio streams
        publishCameraTrack: true, // Publish camera-captured video
        publishMicrophoneTrack: true, // Publish microphone-captured audio
        // Use clientRoleBroadcaster to act as a host or clientRoleAudience for audience
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: uid,
    );
  }

  @override
  Future<void> joinChannelCustom(String channel, int uid) async {
    await _mediaEngine!.setExternalVideoSource(enabled: true, useTexture: false);
    String token = await getChatToken(channel);
    await _engine!.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true, // Automatically subscribe to all video streams
        autoSubscribeAudio: true, // Automatically subscribe to all audio streams
        customVideoTrackId: 0,
        publishCustomVideoTrack: true, // Publish camera-captured video
        publishMicrophoneTrack: true, // Publish microphone-captured audio
        // Use clientRoleBroadcaster to act as a host or clientRoleAudience for audience
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: uid,
    );
  }

  @override
  Future<void> pushExternalVideoFrame(ExternalVideoFrame frame) async{
    await _mediaEngine!.pushVideoFrame(frame: frame);
  }


  @override
  void setupEventHandlers(){
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          _localUserStreamController.add(connection.localUid);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          _remoteUserStreamController.add(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          _remoteUserStreamController.add(null);
        },
        onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
          _remoteUserVideoStreamMuted.add(!muted);
        }
      ),
    );
  }

  @override
  Future<void> setupLocalVideo() async{
    // The video module and preview are disabled by default.
    await _engine!.enableVideo();
    await _engine!.startPreview();
  }


  @override
  Future<void> disableLocalVideo() async {
    await _engine!.enableLocalVideo(false);
    await _engine!.muteLocalVideoStream(true);
    await _engine!.stopPreview();
  }

  @override
  Future<void> enableLocalVideo() async {
    // await _engine!.enableVideo();
    await _engine!.enableLocalVideo(true);
    await _engine!.muteLocalVideoStream(false);
    await _engine!.startPreview();
  }


  @override
  Future<void> cleanupEngine() async{
    await _engine!.leaveChannel();
    await _engine!.release();
  }

  @override
  Future<void> requestPermissions() async{
    await [Permission.microphone, Permission.camera].request();
  }

  @override
  Future<String> getChatToken(String channelName) async {
    var response = await agoraService.getToken(channelName);
    return response.token;
  }

  @override
  Stream<String> getPredictionStream() {
    return frameObserver.getPredictionStream();
  }

  @override
  RtcEngine? getVideoEngine() {
    return _engine;
  }

  @override
  Future<void> disableLocalAudio() async {
    await _engine!.enableLocalAudio(false);
    await _engine!.muteLocalAudioStream(true);
  }

  @override
  Future<void> enableLocalAudio() async {
    await _engine!.enableLocalAudio(true);
    await _engine!.muteLocalAudioStream(false);
  }


}