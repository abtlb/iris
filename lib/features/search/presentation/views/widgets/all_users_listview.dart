import 'package:flutter/material.dart';
import 'package:untitled3/features/auth/domain/entities/UserEntity.dart';
import 'package:untitled3/features/search/presentation/views/widgets/all_users_item.dart';
import 'package:untitled3/features/video_home/domain/entity/ConversationEntity.dart';

class AllUsersListview extends StatelessWidget {
  const AllUsersListview(
      {super.key,
      required this.names,
      required this.senderId,
      required this.receiverIds});
  final List<UserEntity> names;
  final String senderId;
  final List<String> receiverIds;
  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: names.length,
      itemBuilder: (context, index) {
        return AllUsersItem(
          senderId: senderId,
          receiverId: receiverIds[index],
          name: names[index],
        );
      },
    );
  }
}
