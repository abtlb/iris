import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';

class RemoteVideoStates extends Equatable {
  @override
  List<Object?> get props => [];
}

class VideoChatShowRemoteUser extends RemoteVideoStates {
  final int remoteUid;
  final RtcEngine rtcEngine;
  final String channel;
  final bool showVideo;

  VideoChatShowRemoteUser({required this.remoteUid, required this.rtcEngine, required this.channel, required this.showVideo});

  @override
  List<Object?> get props => [remoteUid, rtcEngine, channel, showVideo];
}

class VideoChatNoRemoteUser extends RemoteVideoStates {}