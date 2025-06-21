import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:untitled3/features/chat/domain/usecases/chat_usecase.dart';
import 'package:untitled3/features/video_chat/domain/usecases/GetLocalUserStreamUsecase.dart';
import 'package:untitled3/features/video_chat/domain/usecases/GetRemoteUserStreamUsecase.dart';
import 'package:untitled3/features/video_chat/domain/usecases/connectToVideoChat.dart';
import 'package:untitled3/features/video_chat/domain/usecases/disconnectFromVideoChat.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_events.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_states.dart';

class VideoChatBloc extends Bloc<VideoChatEvent, VideoChatState> {
  final ConnectToVideoChatUsecase connectUsecase;
  final DisconnectFromVideoChatUsecase disconnectUsecase;
  RtcEngine? engine;
  String? channel;

  VideoChatBloc({required this.connectUsecase, required this.disconnectUsecase}): super(VideoChatInitial()) {
    on<VideoChatConnectionRequested>((event, emit) async {
      print("connection requested");
      emit(VideoChatConnecting());

      try {
        print("before calling connectUsecase");
        engine = await connectUsecase.call(event.channelName, 0);
        print("after calling connectUsecase");
        channel = event.channelName;
        emit(VideoChatConnected(rtcEngine: engine!));
      }
      catch(e) {
        print(e.toString());
        emit(VideoChatConnectionFailed(exception: e as Exception));
      }
    });

    on<VideoChatDisconnectRequested>((event, emit) async {
      try {
        await disconnectUsecase.call();
        emit(VideoChatDisconnected());
      }
      catch(e) {
        print(e.toString());
      }
    });
  }

  @override
  Future<void> close() {
    return super.close();
  }

}