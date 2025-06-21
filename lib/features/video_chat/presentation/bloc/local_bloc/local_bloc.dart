import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/features/chat/domain/entities/message.dart';
import 'package:untitled3/features/chat/domain/usecases/chat_usecase.dart';
import 'package:untitled3/features/video_chat/domain/usecases/enableLocalVideo.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/local_bloc/local_events.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/local_bloc/local_states.dart';
import 'package:untitled3/features/video_chat/presentation/widgets/HandTrackingWidget.dart';

import '../../../data/others/asl_detector.dart';
import '../../../domain/usecases/GetLocalUserStreamUsecase.dart';
import '../../../domain/usecases/disableLocalVideo.dart';

class LocalVideoBloc extends Bloc<LocalVideoEvents, LocalVideoStates> {
  final GetLocalUserStreamUsecase getLocalUserStreamUsecase;
  final EnableLocalVideoUsecase enableLocalVideoUsecase;
  final DisableLocalVideoUsecase disableLocalVideoUsecase;
  final ASLDetector aslDetector;
  final HandTrackingManager handTrackingManager = HandTrackingManager.instance;
  final ChatUseCase chatUseCase;
  StreamSubscription<String?>? predictionStreamSub;

  LocalVideoBloc({ required this.getLocalUserStreamUsecase, required this.chatUseCase, required this.enableLocalVideoUsecase, required this.disableLocalVideoUsecase, required this.aslDetector}) : super(LocalVideoInitial()) {
    print("local bloc called");
    on<ShareLocalVideo>((event, emit) async {
      emit(LocalVideoEnabling());
      //disable ASL
      handTrackingManager.dispose();
      await enableLocalVideoUsecase.call();
      emit(LocalVideoEnabled());
    });

    on<ShareASL>((event, emit) async {
      emit(ASLEnabling());
      await disableLocalVideoUsecase.call();
      //enable ASL widget
      predictionStreamSub = aslDetector.predictionStream.listen((prediction) {
        chatUseCase.displayMessage(ChatMessageEntity(receiver: event.receiver, sender: event.sender, time: DateTime.now(),message: prediction));
      });
      handTrackingManager.reset();
      emit(ASLEnabled());
    });

    on<DisableLocalVideo>((event, emit) async {
      emit(LocalVideoDisabling());
      await disableLocalVideoUsecase.call();
      //disable ASL widget
      handTrackingManager.dispose();
      emit(LocalVideoDisabled());
    });
  }

  @override
  Future<void> close() {
    predictionStreamSub?.cancel();
    return super.close();
  }
}