import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/remote_bloc/remote_events.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/remote_bloc/remote_states.dart';

import '../../../domain/usecases/GetRemoteUserStreamUsecase.dart';
import '../../../domain/usecases/getVideoEngine.dart';
import '../../../domain/usecases/getVideoMuteStreamUsecase.dart';

class RemoteVideoBloc extends Bloc<RemoteVideoEvents, RemoteVideoStates> {
  final GetRemoteUserStreamUsecase getRemoteUserStreamUsecase;
  StreamSubscription<int?>? _remoteUidSub;
  final GetVideoMuteStreamUsecase getVideoMuteStreamUsecase;
  StreamSubscription<bool?>? _videoMuteSub;

  late RtcEngine engine;
  late String channel;
  int? remoteUid;

  RemoteVideoBloc({required this.getVideoMuteStreamUsecase, required this.getRemoteUserStreamUsecase}) : super(VideoChatNoRemoteUser()) {
    on<SetupRemoteBloc>((event, emit) {
      channel = event.channel;
      engine = event.engine;

      _remoteUidSub = getRemoteUserStreamUsecase.call().listen((data) {
        if(data == null) {
          add(VideoChatRemoteUserDisconnected());
        }
        else {
          remoteUid = data;
        }
      });

      _videoMuteSub = getVideoMuteStreamUsecase.call().listen((data) {
        if(remoteUid != null) {
          add(UpdateRemoteUserInfo(remoteUid: remoteUid!, rtcEngine: engine, channel: channel, showVideo: data!));
        }
      });
    });

    on<VideoChatRemoteUserDisconnected>((event, emit) async {
      emit(VideoChatNoRemoteUser());
    });

    on<UpdateRemoteUserInfo>((event, emit) async {
      emit(VideoChatShowRemoteUser(remoteUid: event.remoteUid, rtcEngine: event.rtcEngine, channel: event.channel, showVideo: event.showVideo));
    });

    // _remoteUidSub = getRemoteUserStreamUsecase.call().listen((data) {
    //   if(channel != null) {
    //     if(data == null) {
    //       add(VideoChatRemoteUserDisconnected());
    //     } else {
    //       add(VideoChatRemoteUserJoined(remoteUid: data));
    //     }
    //   }
    // });

  }

  @override
  Future<void> close() {
    _remoteUidSub?.cancel();
    _videoMuteSub?.cancel();
    return super.close();
  }
}