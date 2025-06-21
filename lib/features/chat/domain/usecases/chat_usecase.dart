import '../repositories/chat_repository.dart';
import '../entities/message.dart';

class ChatUseCase {
  final ChatRepository chatRepository;

  ChatUseCase(this.chatRepository);

  Future<void> connect() async => await chatRepository.connect();

  void sendMessage(ChatMessageEntity message) {
    chatRepository.sendMessage(message);
  }

  void displayMessage(ChatMessageEntity message) {
    chatRepository.displayMessage(message);
  }

  void onMessageReceived(Function(ChatMessageEntity) callback) {
    chatRepository.onMessageReceived(callback);
  }

  void onDisplayMessageReceived(Function(ChatMessageEntity) callback) {
    chatRepository.onDisplayMessageReceived(callback);
  }

  Future<List<ChatMessageEntity>> loadMessages(String sender, String receiver) async {
    final messages = await chatRepository.loadMessages(sender, receiver);
    messages.sort((a, b) => b.time.compareTo(a.time));
    return messages;
  }

  Future<void> disconnect() => chatRepository.disconnect();
}
