import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/core/util/styles.dart';
import 'package:untitled3/core/util/widgets/custom_iconButton.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/story_item.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.notify,
    required this.senderId,
    required this.receiverId,
    required this.id,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.imageUrl,
    this.onDismissed,
  });

  final int notify;
  final String senderId, receiverId, id;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? imageUrl;
  final Function(DismissDirection)? onDismissed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Dismissible(
        key: Key(id),
        onDismissed: onDismissed,
        background: Container(
          padding: const EdgeInsets.only(left: 30),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(color: Colors.white),
          child: const CustomIconButton(
            size: 40,
            iconSize: 25,
            background: kInfoColor,
            icon: Icons.delete_rounded,
          ),
        ),
        secondaryBackground: Container(
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          decoration: const BoxDecoration(color: Colors.white10),
          child: const CustomIconButton(
            size: 40,
            iconSize: 25,
            background: kInfoColor,
            icon: Icons.delete_rounded,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                GoRouter.of(context).push(
                  AppRoute.kChatPath,
                  extra: {
                    'senderId': senderId,
                    'receiverId': receiverId,
                  },
                );
              },
              leading: StoryItem(
                size: 40,
                sizeImage: 40,
                imageUrl: imageUrl ?? '',
              ),
              title: Text(
                receiverId,
                style: Styles.textStyle18.copyWith(
                  fontWeight: FontWeight.w900,
                  fontFamily: kFont,
                  fontSize: 22,
                ),
              ),
              subtitle: Text(
                lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Styles.textStyle16.copyWith(
                  color: kTextLight,
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _formatMessageTime(lastMessageTime, DateTime.now()),
                    style: Styles.textStyle16.copyWith(
                      color: kTextLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.videocam_rounded),
                  //   color: Colors.blue,
                  //   tooltip: 'Start Video Chat',
                  //   onPressed: () {
                  //     GoRouter.of(context).push(
                  //       AppRoute.videoChatTestPath,
                  //       extra: {
                  //         'username1': senderId,
                  //         'username2': receiverId,
                  //       },
                  //     );
                  //   },
                  // ),
                  notification(),
                ],
              ),
            ),
            Divider(
              color: kContainerColor,
              indent: 110,
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime messageTime, DateTime now) {
    final localMessageTime = messageTime.toLocal();
    final localNow = now.toLocal();

    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      localMessageTime.year,
      localMessageTime.month,
      localMessageTime.day,
    );

    if (messageDate == today) {
      return DateFormat('h:mm a').format(localMessageTime); // e.g. 3:45 PM
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(localMessageTime);
    }
  }

  Widget notification() {
    if (notify == 0) return const SizedBox();
    return Container(
      height: 25,
      width: 25,
      decoration:
      const BoxDecoration(color: kInfoColor, shape: BoxShape.circle),
      child: Center(
        child: Text('$notify', style: Styles.textStyle14),
      ),
    );
  }
}
