import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/features/video_chat/data/others/asl_detector.dart';

import '../../domain/entities/course.dart';
import '../widgets/FloatingLearningHandTracking.dart';
import '../widgets/LearningHandTrackingWidget.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the camera controller when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryColor, kBackgroundColor],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section matching home page design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 50, left: 30, right: 30, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // BACK BUTTON
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: kTextLight),
                                  onPressed: () {
                                    GoRouter.of(context).pop();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // TITLE
                              Text(
                                widget.course.title,
                                style: Styles.textStyle30.copyWith(
                                  color: kTextLight,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: kFont,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main Course Image Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          widget.course.image,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Course Information Container
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                widget.course.title,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: kTextLight,
                                  fontFamily: kFont,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.course.subtitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: kTextLight.withOpacity(0.8),
                                  height: 1.6,
                                  fontFamily: kFont,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),

                              // Extra Image if available
                              if (widget.course.extraImage != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      widget.course.extraImage!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Camera Button
                    GestureDetector(
                      onTap: () {
                        // Open camera
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraPreviewPage(
                              correctPrediction: widget.course.correctPrediction,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              size: 24,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Practice with Camera',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                                fontFamily: kFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Camera Preview Page with updated design
class CameraPreviewPage extends StatefulWidget {
  final String correctPrediction;

  const CameraPreviewPage({super.key, required this.correctPrediction});

  @override
  State<CameraPreviewPage> createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage> {
  String? _prediction;
  late StreamSubscription<String> _predictionStream;

  @override
  void initState() {
    super.initState();
    _predictionStream = GetIt.instance<ASLDetector>().predictionStream.listen((prediction) {
      if (mounted) {
        setState(() {
          _prediction = prediction;
        });
      }
    });
  }

  @override
  void dispose() {
    _predictionStream.cancel();
    LearningHandTrackingManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryColor, kBackgroundColor],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 50, left: 30, right: 30, bottom: 20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: kTextLight),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Camera Practice',
                      style: Styles.textStyle30.copyWith(
                        color: kTextLight,
                        fontWeight: FontWeight.bold,
                        fontFamily: kFont,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Camera Preview
            SizedBox(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: const LearningDraggableHandTracking(),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getStatusColors(),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Message
                  Text(
                    _getMainMessage(),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle30.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: kFont,
                      fontSize: 18,
                      height: 1.3,
                    ),
                  ),

                  // Secondary Message (if needed)
                  if (_getSecondaryMessage().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _getSecondaryMessage(),
                      textAlign: TextAlign.center,
                      style: Styles.textStyle30.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontFamily: kFont,
                        fontSize: 14,
                      ),
                    ),
                  ],

                  // Target Sign Highlight
                  if (_prediction != widget.correctPrediction) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.correctPrediction.toUpperCase(),
                        style: Styles.textStyle30.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: kFont,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // Helper methods for the UI
  List<Color> _getStatusColors() {
    if (_prediction == null) {
      return [
        Colors.blue.withOpacity(0.8),
        Colors.indigo.withOpacity(0.6),
      ];
    } else if (_prediction != widget.correctPrediction) {
      return [
        Colors.orange.withOpacity(0.8),
        Colors.deepOrange.withOpacity(0.6),
      ];
    } else {
      return [
        Colors.green.withOpacity(0.8),
        Colors.teal.withOpacity(0.6),
      ];
    }
  }

  IconData _getStatusIcon() {
    if (_prediction == null) {
      return Icons.gesture;
    } else if (_prediction != widget.correctPrediction) {
      return Icons.refresh;
    } else {
      return Icons.check_circle;
    }
  }

  String _getMainMessage() {
    if (_prediction == null) {
      return "Ready to start? ✨";
    } else if (_prediction != widget.correctPrediction) {
      return "Almost there! 🎯";
    } else {
      return "Perfect! 🎉";
    }
  }

  String _getSecondaryMessage() {
    if (_prediction == null) {
      return "Make the sign for";
    } else if (_prediction != widget.correctPrediction) {
      return "You signed '$_prediction', try again for";
    } else {
      return "You've mastered this sign!";
    }
  }
}