import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/video_home/domain/entity/ConversationEntity.dart';
import 'package:untitled3/features/video_home/presentation/bloc/chat_home_bloc.dart';
import 'package:untitled3/features/video_home/presentation/bloc/chat_home_events.dart';
import 'package:untitled3/features/video_home/presentation/bloc/chat_home_states.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/message_item.dart';

class MessagesListview extends StatefulWidget {
  const MessagesListview({super.key, required this.notify});
  final int notify;

  @override
  State<MessagesListview> createState() => _MessagesListviewState();
}

class _MessagesListviewState extends State<MessagesListview> {
  late String senderId;
  late ChatHomeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ChatHomeBloc>(context);
    bloc.add(ChatHomeLoadConversation());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeBloc, ChatHomeState>(
      builder: (context, state) {
        if (state is ChatHomeInitial) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                strokeWidth: 3.0,
                backgroundColor: Colors.transparent,
              ),
            ),
          );
        } else if (state is ChatHomeLoadingConversationsSuccessful) {
          final senderId = state.senderId;
          var names = state.conversations.map((c) => c.otherUserId).toList();
          var lastMessages = state.conversations.map((c) => c.lastMessage).toList();
          var lastMessagesTimes = state.conversations.map((c) => c.lastMessageTime).toList();
          var imageUrls = state.conversations.map((c) => c.otherUserPfpUrl).toList();

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                          fontFamily: kFont,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${names.length}',
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Messages list
                Container(
                  height: MediaQuery.of(context).size.height * ((names.length + 1) / 10),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: kBlueMedium.withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: kBorderColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: MessageItem(
                          onDismissed: (direction) {
                            setState(() {
                              names.removeAt(index);
                            });
                          },
                          id: names[index],
                          senderId: senderId,
                          receiverId: names[index],
                          lastMessage: lastMessages[index],
                          lastMessageTime: lastMessagesTimes[index],
                          notify: widget.notify,
                          imageUrl: imageUrls[index],
                        ),
                      );
                    },
                  ),
                ),

                // Empty state if no messages
                if (names.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: kBorderColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: kTextPrimary.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start chatting with your friends!',
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextPrimary.withOpacity(0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
              strokeWidth: 3.0,
              backgroundColor: kBackgroundColor.withOpacity(0.3),
            ),
          ),
        );
      },
      listener: (context, state) {
        // Handle state changes if needed
      },
    );
  }
}