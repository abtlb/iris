import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';

class RemoteVideoEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetupStreams extends RemoteVideoEvents {}

class SetupRemoteBloc extends RemoteVideoEvents {
  final String channel;
  final RtcEngine engine;

  SetupRemoteBloc({required this.channel, required this.engine});

  @override
  List<Object?> get props => [channel, engine];
}

class UpdateRemoteUserInfo extends RemoteVideoEvents {
  final int remoteUid;
  final RtcEngine rtcEngine;
  final String channel;
  final bool showVideo;

  UpdateRemoteUserInfo({required this.remoteUid, required this.rtcEngine, required this.channel, required this.showVideo});

  @override
  List<Object?> get props => [remoteUid, rtcEngine, channel, showVideo];
}

class VideoChatRemoteUserDisconnected extends RemoteVideoEvents {}
