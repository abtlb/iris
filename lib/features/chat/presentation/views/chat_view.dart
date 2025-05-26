import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/features/chat/presentation/views/widgets/chatView_body.dart';

import '../../../../core/util/app_route.dart';

class ChatView extends StatelessWidget {
  final String senderId;
  final String receiverId;
  const ChatView({super.key, required this.senderId, required this.receiverId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // navigate to home
          GoRouter.of(context).push(AppRoute.chatHomePath);
        }
      },
      child: Scaffold(
        body: ChatviewBody(senderId: senderId, receiverId: receiverId,),
      ));
  }
}
