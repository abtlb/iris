import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_bloc.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_states.dart';
import '../bloc/remote_bloc/remote_bloc.dart';
import '../bloc/remote_bloc/remote_states.dart';
import '../widgets/RemoteVideoWidget.dart';

/// A draggable, floating remote preview that listens to VideoChatBloc.
///
/// Place this inside a Stack. It tracks its own position (Offset) and
/// responds to drag gestures.
class DraggableRemotePreview extends StatefulWidget {
  final RtcEngine engine;

  DraggableRemotePreview({Key? key, required this.engine}) : super(key: key);

  @override
  State<DraggableRemotePreview> createState() => _DraggableRemotePreviewState();
}

class _DraggableRemotePreviewState extends State<DraggableRemotePreview> {
  // Initial position (you can tweak these values).
  Offset _position = const Offset(20, 300);

  @override
  initState() {
    super.initState();
    var bloc = BlocProvider.of<RemoteVideoBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteVideoBloc, RemoteVideoStates>(
      builder: (context, state) {
        // Always wrap in a Positioned so we can move it around.
        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanStart: (_) {
              // If you want to add something when dragging starts, do it here.
            },
            onPanUpdate: (details) {
              // User drags: update the offset by the delta movement
              setState(() {
                _position = Offset(
                  _position.dx + details.delta.dx,
                  _position.dy + details.delta.dy,
                );
              });
            },
            onPanEnd: (_) {
              // If you want to snap to edges or do something on drag end, handle here.
            },
            child: _buildPreviewContent(state),
          ),
        );
      },
    );
  }

  /// Build the inner box: either the remote video or a loading placeholder.
  Widget _buildPreviewContent(RemoteVideoStates state) {
    // Decide what to show based on your BLoC state:
    if (state is VideoChatShowRemoteUser && state.showVideo == true) {
      final engine = widget.engine;
      final remoteUid = state.remoteUid;
      final channel = state.channel;

      return Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: RemoteVideoWidget(
            engine: engine,
            remoteUid: remoteUid,
            channel: channel,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
