import 'dart:async';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/features/chat/presentation/blocs/voice/voice_bloc.dart';
import 'package:untitled3/features/chat/presentation/blocs/voice/voice_event.dart';
import 'package:untitled3/features/chat/presentation/views/widgets/StringStreamDisplayer.dart';
import 'package:untitled3/features/chat/presentation/views/widgets/chat_listView.dart';
import 'package:untitled3/features/chat/presentation/views/widgets/custom_appBarChat.dart';
import 'package:untitled3/features/chat/presentation/views/widgets/custom_textField.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/remote_bloc/remote_states.dart';
import 'package:untitled3/features/video_chat/presentation/widgets/FloatingLocalPreview.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../video_chat/domain/utils/channel_name_generator.dart';
import '../../../../video_chat/presentation/bloc/connection_bloc/video_chat_bloc.dart';
import '../../../../video_chat/presentation/bloc/connection_bloc/video_chat_events.dart';
import '../../../../video_chat/presentation/bloc/connection_bloc/video_chat_states.dart';
import '../../../../video_chat/presentation/bloc/local_bloc/local_bloc.dart';
import '../../../../video_chat/presentation/bloc/local_bloc/local_events.dart';
import '../../../../video_chat/presentation/bloc/local_bloc/local_states.dart';
import '../../../../video_chat/presentation/bloc/remote_bloc/remote_bloc.dart';
import '../../../../video_chat/presentation/bloc/remote_bloc/remote_events.dart';
import '../../../../video_chat/presentation/widgets/FloatingHandTracking.dart';
import '../../../../video_chat/presentation/widgets/FloatingRemotePreview.dart';
import '../../../../video_chat/presentation/widgets/VideoAudioMenuButton.dart';
import '../../../domain/entities/message.dart';
import '../../blocs/chat_bloc.dart';
import '../../blocs/chat_events.dart';
import '../../blocs/chat_states.dart';

class ChatviewBody extends StatefulWidget {
  final String senderId;
  final String receiverId;

  const ChatviewBody({
    super.key,
    required this.senderId,
    required this.receiverId,
  });

  @override
  State<ChatviewBody> createState() => _ChatviewBodyState();
}

class _ChatviewBodyState extends State<ChatviewBody>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> formKey1 = GlobalKey();
  final ScrollController controller = ScrollController();
  final TextEditingController textEditingController = TextEditingController();

  late ChatBloc _chatBloc;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? text;
  late String channelName;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _chatBloc.add(ChatLoadMessages(sender: widget.senderId, receiver: widget.receiverId));

    channelName = ChannelNameGenerator.makeChannelName(widget.senderId, widget.receiverId);
    context.read<VideoChatBloc>().add(VideoChatConnectionRequested(
      channelName: channelName,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    textEditingController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _chatBloc.add(ChatDisconnect());
    super.dispose();
  }

  void _sendMessage(String data) {
    if (data.trim().isEmpty) return;

    final message = ChatMessageEntity(
      sender: widget.senderId,
      receiver: widget.receiverId,
      message: data.trim(),
      time: DateTime.now(),
    );

    _chatBloc.add(ChatSendMessage(message: message));
    textEditingController.clear();
    text = null;

    // Add a small haptic feedback
    HapticFeedback.lightImpact();
  }

  void _scrollToBottom() {
    if (controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kPrimaryColor.withOpacity(0.9),
              kBackgroundColor.withOpacity(0.95),
              Colors.white.withOpacity(0.1),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: formKey1,
            child: Stack(
              children: [
                // Main content with improved layout
                Column(
                  children: [
                    // Top section with video controls
                    _buildTopSection(),

                    // Chat messages area
                    Expanded(
                      child: _buildChatSection(),
                    ),

                    // Input field with better design
                    _buildInputSection(),
                  ],
                ),

                // Floating elements
                ..._buildFloatingElements(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // User info section
            Expanded(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      context.read<ChatBloc>().add(ChatDisconnect());
                      context.read<LocalVideoBloc>().add(DisableLocalVideo());
                      //todo: i don't know if anything should be done to the remote bloc
                      context.read<RemoteVideoBloc>().close();
                      context.read<VoiceBloc>().add(DisableVoice());
                      context.read<VideoChatBloc>().add(VideoChatDisconnectRequested());

                      GoRouter.of(context).pop();
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.7)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.receiverId.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IconButton(
                        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
                        //   onPressed: () => GoRouter.of(context).pop(),
                        // ),
                        Text(
                          widget.receiverId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Video controls
            VideoAudioMenuButton(
              sender: widget.senderId,
              receiver: widget.receiverId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Messages list
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return _buildLoadingIndicator();
                  } else if (state is ChatMessagesLoadingSuccess) {
                    return _buildMessagesList(state);
                  } else if (state is ChatMessagesLoadingFailure) {
                    return _buildErrorState(state);
                  }
                  return _buildEmptyState();
                },
                listener: (context, state) {
                  if (state is ChatMessagesLoadingSuccess) {
                    _scrollToBottom();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 40,
        bottom: _isKeyboardVisible ? 20 : 30,
        top: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: CustomTextfield(
                controller: textEditingController,
                onSubmitted: (data) {
                  if (formKey1.currentState!.validate()) {
                    _sendMessage(data);
                  }
                },
                onChanged: (value) {
                  text = value;
                },
                onTap: () {
                  if (formKey1.currentState!.validate() &&
                      text != null &&
                      text!.trim().isNotEmpty) {
                    _sendMessage(text!);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send button with animation
          // AnimatedContainer(
          //   duration: const Duration(milliseconds: 200),
          //   width: 50,
          //   height: 50,
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
          //     ),
          //     borderRadius: BorderRadius.circular(25),
          //     boxShadow: [
          //       BoxShadow(
          //         color: kPrimaryColor.withOpacity(0.3),
          //         blurRadius: 8,
          //         offset: const Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Material(
          //     color: Colors.transparent,
          //     child: InkWell(
          //       borderRadius: BorderRadius.circular(25),
          //       onTap: () {
          //         if (formKey1.currentState!.validate() &&
          //             text != null &&
          //             text!.trim().isNotEmpty) {
          //           _sendMessage(text!);
          //         }
          //       },
          //       child: const Icon(
          //         Icons.send_rounded,
          //         color: Colors.white,
          //         size: 24,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatMessagesLoadingSuccess state) {
    final messages = state.messages.map((msg) =>
    msg is ChatMessageEntity ? msg.message : msg.message
    ).toList();
    final times = state.messages.map((msg) =>
    msg is ChatMessageEntity ? msg.time : msg.time
    ).toList();
    final senderIds = state.messages.map((msg) =>
    msg is ChatMessageEntity ? msg.sender : msg.sender
    ).toList();

    return ChatListview(
      controller: controller,
      messages: messages,
      name: widget.receiverId,
      time: times,
      senderIds: senderIds,
      currentUserId: widget.senderId,
    );
  }

  Widget _buildErrorState(ChatMessagesLoadingFailure state) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              "Failed to load messages",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _chatBloc.add(ChatLoadMessages(
                  sender: widget.senderId,
                  receiver: widget.receiverId,
                ));
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No messages yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start the conversation!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingElements(BuildContext context) {
    return [
      // String Stream Displayer
      Positioned(
        top: MediaQuery.of(context).size.height / 14,
        // top: 0,
        right: 0,
        width: MediaQuery.of(context).size.width,
        child: const StringStreamDisplayer(height: 200,),
      ),

      // Local Video Preview
      BlocBuilder<VideoChatBloc, VideoChatState>(
        builder: (BuildContext context, VideoChatState state) {
          if (state is VideoChatConnected) {
            final engine = state.engine!;
            return DraggableLocalPreview(engine: engine);
          }
          return const SizedBox.shrink();
        },
      ),

      // Hand Tracking
      BlocBuilder<VideoChatBloc, VideoChatState>(
        builder: (BuildContext context, VideoChatState state) {
          if (state is VideoChatConnected) {
            return Positioned(
              top: MediaQuery.of(context).size.height / 13 + 120, // under the string stream displayer
              right: 20,
              child: const DraggableHandTracking(),
            );
          }
          return const SizedBox.shrink();
        },
      ),

      // Remote Video Preview
      BlocBuilder<VideoChatBloc, VideoChatState>(
        builder: (BuildContext context, VideoChatState state) {
          if (state is VideoChatConnected) {
            final engine = state.engine!;
            context.read<RemoteVideoBloc>().add(
                SetupRemoteBloc(channel: channelName, engine: engine)
            );
            return DraggableRemotePreview(engine: engine);
          }
          return const SizedBox.shrink();
        },
      ),
    ];
  }
}