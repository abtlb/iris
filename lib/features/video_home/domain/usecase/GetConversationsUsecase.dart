import 'package:untitled3/features/video_home/domain/entity/ConversationEntity.dart';
import 'package:untitled3/features/video_home/domain/repository/ChatHomeRepository.dart';

class GetConversationsUsecase {
  final ChatHomeRepository chatHomeRepository;

  GetConversationsUsecase({required this.chatHomeRepository});

  Future <List<ConversationEntity>> call() async {
    return chatHomeRepository.getConversations();
  }
}