import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/features/chat/domain/entities/message.dart';
import 'package:untitled3/features/chat/domain/usecases/chat_usecase.dart';
import 'package:untitled3/features/chat/presentation/blocs/voice/voice_event.dart';
import 'package:untitled3/features/chat/presentation/blocs/voice/voice_state.dart';
import 'package:untitled3/features/video_chat/domain/usecases/disableLocalAudio.dart';
import 'package:untitled3/features/video_chat/domain/usecases/enableLocalAudio.dart';
import 'package:untitled3/features/video_chat/services/%20speech_to_text_service.dart';

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  SpeechToTextService speechToTextService;
  EnableLocalAudioUsecase enableLocalAudio;
  DisableLocalAudioUsecase disableLocalAudio;
  ChatUseCase chatUseCase;

  VoiceBloc({required this.speechToTextService, required this.chatUseCase, required this.enableLocalAudio, required this.disableLocalAudio}): super(VoiceDisabled()) {
    on<ShareVoice>((event, emit) async {
      await speechToTextService.stopListening();
      await enableLocalAudio.call();
      emit(SharingVoice());
    });

    on<DoSTT>((event, emit) async {
      print("enabling sst");
      await disableLocalAudio.call();
      await speechToTextService.initialize();
      await speechToTextService.startListening(
              (result) {
        chatUseCase.displayMessage(ChatMessageEntity(receiver: event.receiver, time: DateTime.now(), sender: event.sender, message: "$result\n"));
      });
      emit(DoingSTT());
    });

    on<DisableVoice>((event, emit) async {
      await speechToTextService.stopListening();
      await disableLocalAudio.call();
      emit(VoiceDisabled());
    });
  }
}