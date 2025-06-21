import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/features/learning/presentation/widgets/LearningHandTrackingWidget.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/local_bloc/local_states.dart';

/// Wraps HandTrackingWidget in a draggable container.
/// Only shows the tracker when [isEnabled] is true.
class LearningDraggableHandTracking extends StatefulWidget {

  const LearningDraggableHandTracking({Key? key}) : super(key: key);

  @override
  State<LearningDraggableHandTracking> createState() => _LearningDraggableHandTrackingState();
}

class _LearningDraggableHandTrackingState extends State<LearningDraggableHandTracking> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
            return Container(
              width: width * 7 / 8,
              height: height * 0.4,
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
                child: LearningHandTrackingWidget(),
              ),
            );
  }
}
