import 'package:untitled3/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  Future<void> connect();
  Future<void> disconnect();
  void sendMessage(ChatMessageEntity message);
  void displayMessage(ChatMessageEntity message);
  Future<List<ChatMessageEntity>> loadMessages(String senderId, String receiverId);
  void onMessageReceived(Function(ChatMessageEntity) callback);
  void onDisplayMessageReceived(Function(ChatMessageEntity) callback);
}