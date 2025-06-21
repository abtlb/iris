import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/features/chat/data/models/message.dart';

import '../../../domain/entities/displayMessage.dart';

/// A widget that listens to a Stream<String> and accumulates
/// incoming messages into a single display buffer. If the buffer
/// exceeds [maxBufferLength], it discards oldest characters.
/// If no new message arrives for 10 seconds, it clears everything.
class StringStreamDisplayer extends StatefulWidget {
  /// Maximum number of characters to keep in the buffer.
  final int maxBufferLength;

  /// Optional style for the displayed text.
  final TextStyle? textStyle;

  /// Optional background color for the display area.
  final Color backgroundColor;

  /// Height of the widget (required for proper layout)
  final double? height;

  /// Creates a StringStreamDisplayer.
  const StringStreamDisplayer({
    Key? key,
    this.maxBufferLength = 2000, // Increased for better text display
    this.textStyle,
    this.backgroundColor = Colors.black87,
    this.height, // Add height parameter
  }) : super(key: key);

  @override
  State<StringStreamDisplayer> createState() => _StringStreamDisplayerState();
}

class _StringStreamDisplayerState extends State<StringStreamDisplayer> {
  late StreamSubscription<DisplayMessageEntity> _subscription;
  final StringBuffer _buffer = StringBuffer();
  String _displayText = "";
  bool usernameWritten = false;
  Timer? _clearTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen to the shared StreamController<String> from GetIt:
    final messageStream = GetIt.instance<StreamController<DisplayMessageEntity>>().stream;
    _subscription = messageStream.listen((incoming) {
      // 1) Cancel any pending "clear" timer because new input arrived:
      _clearTimer?.cancel();

      // 2) Append the new message with better formatting:
      if (!usernameWritten) {
        _buffer.writeln("${incoming.name}:");
        usernameWritten = true;
      }
      _buffer.write(incoming.message);

      // 3) Smart buffer management - trim by lines, not characters
      if (_buffer.length > widget.maxBufferLength) {
        final lines = _buffer.toString().split('\n');
        // Keep the last 80% of lines to maintain context
        final linesToKeep = (lines.length * 0.8).floor();
        final trimmedLines = lines.sublist(lines.length - linesToKeep);
        _buffer
          ..clear()
          ..write(trimmedLines.join('\n'));
      }

      // 4) Update the displayed text:
      setState(() {
        _displayText = _buffer.toString();
      });

      // 5) Auto-scroll to bottom with a slight delay to ensure content is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });

      // 6) Start a new 30-second timer (increased from 10) to clear if no further input:
      _clearTimer = Timer(const Duration(seconds: 10), () {
        _buffer.clear();
        setState(() {
          _displayText = "";
          usernameWritten = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _clearTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _displayText.isEmpty? SizedBox.shrink() : Container(
      // Add explicit height constraint
      height: widget.height ?? 300, // Default height if not provided
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.backgroundColor.withOpacity(0.95),
            widget.backgroundColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Optional header with subtle indicator
              if (_displayText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Stream',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              // Main content area
              Expanded(
                child: _displayText.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(
                      //   Icons.chat_bubble_outline,
                      //   color: Colors.white.withOpacity(0.3),
                      //   size: 48,
                      // ),
                      // const SizedBox(height: 12),
                      Text(
                        'Waiting for messages...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.topLeft,
                    child: SelectableText(
                      _displayText,
                      style: widget.textStyle ??
                          TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 14,
                            fontFamily: 'SF Mono',
                            fontFamilyFallback: const [
                              'Monaco',
                              'Consolas',
                              'Courier New',
                              'monospace'
                            ],
                            height: 1.6, // Increased line height for better readability
                            letterSpacing: 0.3,
                            wordSpacing: 1.2,
                          ),
                      textAlign: TextAlign.left,
                      cursorColor: Colors.cyan.withOpacity(0.8),
                      // selectionColor: Colors.cyan.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}