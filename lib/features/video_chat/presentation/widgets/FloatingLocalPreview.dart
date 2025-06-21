import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_bloc.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/connection_bloc/video_chat_states.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/local_bloc/local_bloc.dart';
import '../bloc/local_bloc/local_states.dart';
import '../bloc/remote_bloc/remote_states.dart';
import '../widgets/LocalVideoWidget.dart';

/// A draggable, floating local video preview that listens to VideoChatBloc.
///
/// Place this inside a Stack. It tracks its own position (Offset) and
/// responds to drag gestures.
class DraggableLocalPreview extends StatefulWidget {
  final RtcEngine engine;
   DraggableLocalPreview({Key? key, required this.engine}) : super(key: key);

  @override
  State<DraggableLocalPreview> createState() => _DraggableLocalPreviewState();
}

class _DraggableLocalPreviewState extends State<DraggableLocalPreview> {
  // Initial position (adjust as needed)
  Offset _position = const Offset(40, 300);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalVideoBloc, LocalVideoStates>(
      builder: (context, state) {
        return Positioned(
          right: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                final newDx = _position.dx - details.delta.dx;
                final newDy = _position.dy + details.delta.dy;
                // Optional: clamp within screen bounds
                final screenSize = MediaQuery.of(context).size;
                final maxX = screenSize.width - 120;   // box width
                final maxY = screenSize.height - 160 - MediaQuery.of(context).padding.top;
                _position = Offset(
                  newDx.clamp(0.0, maxX),
                  newDy.clamp(0.0, maxY),
                );
              });
            },
            child: _buildPreviewContent(state),
          ),
        );
      },
    );
  }

  /// Builds the inner box: either the local video or a loading placeholder.
  Widget _buildPreviewContent(LocalVideoStates state) {
    if (state is LocalVideoEnabled) {
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
          child: LocalVideoWidget(engine: widget.engine),
        ),
      );
    }

    if(state is LocalVideoEnabling) {

      return Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
