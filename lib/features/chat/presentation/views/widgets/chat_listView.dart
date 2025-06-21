import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled3/features/chat/presentation/views/widgets/chatAnother_container.dart';
import 'package:untitled3/features/chat/presentation/views/widgets/chat_container.dart';

import '../../../../../core/constants/constants.dart';

class ChatListview extends StatefulWidget {
  const ChatListview({
    super.key,
    required this.controller,
    required this.messages,
    required this.name,
    required this.time,
    required this.senderIds,
    required this.currentUserId,
  });

  final ScrollController controller;
  final List<String> messages;
  final List<DateTime> time;
  final List<String> senderIds;
  final String name;
  final String currentUserId;

  @override
  State<ChatListview> createState() => _ChatListviewState();
}

class _ChatListviewState extends State<ChatListview>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _scrollAnimationController;
  late Animation<double> _fadeAnimation;

  final List<AnimationController> _messageAnimationControllers = [];
  final List<Animation<Offset>> _slideAnimations = [];
  final List<Animation<double>> _scaleAnimations = [];

  bool _showScrollToBottomButton = false;
  DateTime? _lastMessageTime;

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize message animations
    _initializeMessageAnimations();

    // Setup scroll listener
    widget.controller.addListener(_scrollListener);

    // Start animations
    _listAnimationController.forward();
  }

  void _initializeMessageAnimations() {
    for (int i = 0; i < widget.messages.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 50)),
        vsync: this,
      );

      final slideAnimation = Tween<Offset>(
        begin: Offset(widget.senderIds[i] == widget.currentUserId ? 1.0 : -1.0, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));

      final scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));

      _messageAnimationControllers.add(controller);
      _slideAnimations.add(slideAnimation);
      _scaleAnimations.add(scaleAnimation);

      // Stagger the animations
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  void _scrollListener() {
    if (widget.controller.hasClients) {
      final showButton = widget.controller.offset > 200;
      if (showButton != _showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = showButton;
        });
      }
    }
  }

  void _scrollToBottom() {
    HapticFeedback.lightImpact();
    widget.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _shouldShowDateDivider(int index) {
    if (index == widget.messages.length - 1) return true;

    final currentDate = widget.time[index];
    final nextDate = widget.time[index + 1];

    return currentDate.day != nextDate.day ||
        currentDate.month != nextDate.month ||
        currentDate.year != nextDate.year;
  }

  String _formatDateForDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            _formatDateForDivider(date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 80, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(0.8),
                  kPrimaryColor.withOpacity(0.6),
                ],
              ),
            ),
            child: Center(
              child: Text(
                widget.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildTypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            final delay = index * 0.2;
            final animationValue = (value - delay).clamp(0.0, 1.0);
            final opacity = (sin(animationValue * pi * 2) + 1) / 2;

            return Container(
              margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
              child: AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildScrollToBottomButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _showScrollToBottomButton ? 20 : -60,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _scrollToBottom,
            child: Container(
              width: 56,
              height: 56,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(int index) {
    final senderId = widget.senderIds[index];
    final isCurrentUser = senderId == widget.currentUserId;

    // Animation setup for individual messages
    if (index < _messageAnimationControllers.length) {
      return SlideTransition(
        position: _slideAnimations[index],
        child: ScaleTransition(
          scale: _scaleAnimations[index],
          child: Column(
            children: [
              // Date divider
              if (_shouldShowDateDivider(index))
                _buildDateDivider(widget.time[index]),

              // Message container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: isCurrentUser
                    ? ChatContainer(
                  text: widget.messages[index],
                  time: widget.time[index],
                  senderId: senderId,
                  currentUserId: widget.currentUserId,
                )
                    : ChatAnotherContainer(
                  text: widget.messages[index],
                  time: widget.time[index],
                  senderId: senderId,
                  currentUserId: widget.currentUserId,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Fallback without animation for safety
    return Column(
      children: [
        if (_shouldShowDateDivider(index))
          _buildDateDivider(widget.time[index]),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: isCurrentUser
              ? ChatContainer(
            text: widget.messages[index],
            time: widget.time[index],
            senderId: senderId,
            currentUserId: widget.currentUserId,
          )
              : ChatAnotherContainer(
            text: widget.messages[index],
            time: widget.time[index],
            senderId: senderId,
            currentUserId: widget.currentUserId,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            kPrimaryColor.withOpacity(0.05),
            kBackgroundColor.withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Chat messages list
          FadeTransition(
            opacity: _fadeAnimation,
            child: widget.messages.isEmpty
                ? _buildEmptyState()
                : CustomScrollView(
              controller: widget.controller,
              reverse: true,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 1,
                    top: 8,
                    bottom: 20,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMessageItem(index),
                      childCount: widget.messages.length,
                    ),
                  ),
                ),
                // Add typing indicator if needed
                // SliverToBoxAdapter(
                //   child: _buildTypingIndicator(),
                // ),
              ],
            ),
          ),

          // Scroll to bottom button
          _buildScrollToBottomButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Start your conversation",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Send a message to ${widget.name}",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _scrollAnimationController.dispose();

    for (final controller in _messageAnimationControllers) {
      controller.dispose();
    }

    widget.controller.removeListener(_scrollListener);
    super.dispose();
  }
}