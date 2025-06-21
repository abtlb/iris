// import 'dart:async';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:untitled3/features/chat/domain/entities/message.dart';
// import 'package:untitled3/features/chat/domain/usecases/chat_usecase.dart';
// import 'package:untitled3/features/chat/presentation/blocs/chat_events.dart';
//
// import '../../domain/entities/displayMessage.dart';
// import 'chat_states.dart';
//
// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final ChatUseCase chatUseCase;
//
//   ChatBloc({required this.chatUseCase}) : super(ChatInitial()){
//     on<ChatMessageReceived>((event, emit) async {
//       emit(ChatAddingMessage(message: event.message));
//     });
//
//     on<ChatSendMessage>((event, emit) async {
//       chatUseCase.sendMessage(event.message);
//       emit(ChatAddingMessage(message: event.message));
//       emit(ChatAddingMessage(message: event.message));
//     });
//
//     on<ChatLoadMessages>((event, emit) async {
//       emit(ChatLoading());
//       try{
//         final messages = await chatUseCase.loadMessages(event.sender, event.receiver);
//
//         chatUseCase.onMessageReceived((ChatMessageEntity message) {
//           add(ChatMessageReceived(message: message));
//         });
//
//         emit(ChatMessagesLoadingSuccess(messages: messages));
//       }
//       catch(e) {
//         emit(ChatMessagesLoadingFailure(error: e.toString()));
//       }
//     });
//
//     on<ChatUpdateMessages>((event, emit) async {
//       emit(ChatUpdating());
//     });
//
//     on<ChatDisconnect>((event, emit) async {
//       try{
//         await chatUseCase.disconnect();
//       }
//       catch(e) {
//         rethrow;
//       }
//     });
//
//   }
//
// }

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/features/chat/domain/entities/message.dart';
import 'package:untitled3/features/chat/domain/usecases/chat_usecase.dart';
import 'package:untitled3/features/chat/presentation/blocs/chat_events.dart';

import '../../domain/entities/displayMessage.dart';
import 'chat_states.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase chatUseCase;
  final displayStream = GetIt.instance<StreamController<DisplayMessageEntity>>();
  List<ChatMessageEntity> _currentMessages = [];

  ChatBloc({required this.chatUseCase}) : super(ChatInitial()) {

    on<ChatMessageReceived>((event, emit) async {
      // Add the received message to current messages
      _currentMessages.add(event.message);

      // Sort messages by time to maintain chronological order
      _currentMessages.sort((a, b) => b.time.compareTo(a.time));

      emit(ChatMessagesLoadingSuccess(messages: List.from(_currentMessages)));
    });

    on<ChatSendMessage>((event, emit) async {
      try {
        // Add message to local list for immediate UI update
        _currentMessages.add(event.message);

        // Sort messages by time to maintain chronological order
        _currentMessages.sort((a, b) => b.time.compareTo(a.time));

        // Emit success with updated messages immediately for UI responsiveness
        emit(ChatMessagesLoadingSuccess(messages: List.from(_currentMessages)));

        // Send message through use case (this might be async)
        chatUseCase.sendMessage(event.message);

      } catch (e) {
        // Remove the message from local list if sending failed
        _currentMessages.removeWhere((msg) =>
        msg.sender == event.message.sender &&
            msg.receiver == event.message.receiver &&
            msg.message == event.message.message &&
            msg.time == event.message.time
        );

        emit(ChatMessagesLoadingFailure(error: e.toString()));
      }
    });

    on<ChatLoadMessages>((event, emit) async {
      emit(ChatLoading());
      try {
        final messages = await chatUseCase.loadMessages(event.sender, event.receiver);

        // Convert models to entities and store locally
        _currentMessages = messages.map((model) => ChatMessageEntity.fromModel(model)).toList();

        // Sort messages by time (newest first for chat display)
        _currentMessages.sort((a, b) => b.time.compareTo(a.time));

        chatUseCase.onMessageReceived((ChatMessageEntity message) {
          add(ChatMessageReceived(message: message));
        });

        chatUseCase.onDisplayMessageReceived(
                (message) {
          displayStream.add(DisplayMessageEntity(name: message.sender, message: message.message));
        });

        emit(ChatMessagesLoadingSuccess(messages: List.from(_currentMessages)));

      } catch (e) {
        emit(ChatMessagesLoadingFailure(error: e.toString()));
      }
    });

    on<ChatUpdateMessages>((event, emit) async {
      // Sort messages by time before emitting
      _currentMessages.sort((a, b) => b.time.compareTo(a.time));
      emit(ChatMessagesLoadingSuccess(messages: List.from(_currentMessages)));
    });

    on<ChatDisconnect>((event, emit) async {
      try {
        // Disconnect from chat service
        await chatUseCase.disconnect();

        // Clear messages and reset state
        _currentMessages.clear();
        emit(ChatInitial());

      } catch (e) {
        emit(ChatMessagesLoadingFailure(error: e.toString()));
      }
    });
  }
}