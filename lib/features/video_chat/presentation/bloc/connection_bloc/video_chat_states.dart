import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';

abstract class VideoChatState extends Equatable {
  late final RtcEngine? engine;
  @override
  List<Object?> get props => [];
}

class VideoChatInitial extends VideoChatState {}
class VideoChatConnecting extends VideoChatState {}
class VideoChatConnected extends VideoChatState {
  final RtcEngine rtcEngine;

  VideoChatConnected({required this.rtcEngine}){ engine = rtcEngine; }
}

class VideoChatDisconnected extends VideoChatState{}

class VideoChatConnectionFailed extends VideoChatState {
  final Exception exception;

  VideoChatConnectionFailed({required this.exception});
}

// class VideoChatRemoteUidUpdated extends VideoChatState{
//   final int? remoteUid;
//
//   VideoChatRemoteUidUpdated({required this.remoteUid});
//
//   @override
//   List<Object?> get props => [remoteUid];
// }
//
// class VideoChatLocalUidUpdated extends VideoChatState{
//   final int? localUid;
//
//   VideoChatLocalUidUpdated({required this.localUid});
//
//   @override
//   List<Object?> get props => [localUid];
// }

