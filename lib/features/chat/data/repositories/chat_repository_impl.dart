import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:untitled3/features/chat/data/data_sources/chat_source.dart';
import 'package:untitled3/features/chat/data/models/message.dart';
import 'package:untitled3/features/chat/domain/entities/message.dart';
import 'package:untitled3/features/chat/domain/repositories/chat_repository.dart';

import '../../domain/entities/displayMessage.dart';

class ChatRepositoryImpl extends ChatRepository {

  final ChatService chatService;

  ChatRepositoryImpl(this.chatService);


  @override
  Future<void> connect() async{
    await chatService.connect();
  }

  @override
  Future<void> disconnect() async{
    await chatService.disconnect();
  }

  @override
  void sendMessage(ChatMessageEntity message) {
    final model = ChatMessageModel(sender: message.sender, receiver: message.receiver, message: message.message, time: message.time);
    chatService.sendMessage(model);
  }

  @override
  void displayMessage(ChatMessageEntity message) {
    final model = ChatMessageModel(sender: message.sender, receiver: message.receiver, message: message.message, time: message.time);
    GetIt.instance<StreamController<DisplayMessageEntity>>().add(DisplayMessageEntity(name: message.sender, message: message.message));
    chatService.displayMessage(model);
  }

  @override
  Future<List<ChatMessageEntity>> loadMessages(String senderId, String receiverId) async {
    final messages = await chatService.loadMessages(senderId, receiverId);
    return messages;
  }

  @override
  void onMessageReceived(Function(ChatMessageEntity) callback) {
    chatService.onMessageReceived(callback);
  }

  @override
  void onDisplayMessageReceived(Function(ChatMessageEntity) callback) {
    chatService.onDisplayMessageReceived(callback);
  }
}