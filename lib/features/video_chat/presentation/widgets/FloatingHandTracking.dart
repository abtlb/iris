import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/local_bloc/local_states.dart';
import '../bloc/local_bloc/local_bloc.dart';
import 'HandTrackingWidget.dart'; // your existing widget

/// Wraps HandTrackingWidget in a draggable container.
/// Only shows the tracker when [isEnabled] is true.
class DraggableHandTracking extends StatefulWidget {

  const DraggableHandTracking({Key? key}) : super(key: key);

  @override
  State<DraggableHandTracking> createState() => _DraggableHandTrackingState();
}

class _DraggableHandTrackingState extends State<DraggableHandTracking> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalVideoBloc, LocalVideoStates>(
      builder: (context, state) {
        if(state is ASLEnabled) {
          return Container(
            width: 150,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: HandTrackingWidget(),
            ),
          );
        }
        return const SizedBox.shrink();
      }
    );
  }
}
