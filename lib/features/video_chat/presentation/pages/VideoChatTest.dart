import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/video_chat_bloc.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/video_chat_events.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/video_chat_states.dart';
import 'package:untitled3/core/util/app_route.dart';
import '../../../tflite_helper.dart';
import '../widgets/LocalVideoWidget.dart';
import '../widgets/RemoteVideoWidget.dart';
import '../../domain/utils/channel_name_generator.dart';

class VideoChatTestPage extends StatefulWidget {
  final String username1;
  final String username2;

  const VideoChatTestPage({super.key, required this.username1, required this.username2});

  @override
  State<VideoChatTestPage> createState() => _VideoChatTestPageState();
}

class _VideoChatTestPageState extends State<VideoChatTestPage> {
  late CameraController _aslCameraController;
  late ASLDetector _aslDetector;
  String _currentPrediction = "None";
  bool _isProcessingFrame = false;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeASLSystem();
    context.read<VideoChatBloc>().add(VideoChatConnectionRequested(
      channelName: ChannelNameGenerator.makeChannelName(widget.username1, widget.username2),
    ));
  }

  Future<void> _initializeASLSystem() async {
    try {
      print("[DEBUG] Loading ASL model...");
      _aslDetector = ASLDetector();
      await _aslDetector.loadModel();
      print("[DEBUG] ASL model loaded.");

      final cameras = await availableCameras();
      print("[DEBUG] Available cameras: ${cameras.length}");

      _aslCameraController = CameraController(
        cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front),
        ResolutionPreset.medium,
      );

      await _aslCameraController.initialize();
      _isCameraReady = true;
      print("[DEBUG] Camera initialized and ready.");

      _aslCameraController.startImageStream(_processCameraFrame);
      print("[DEBUG] Camera image stream started.");
    } catch (e) {
      print("[ERROR] Camera initialization error: $e");
    }
  }

  int _frameCount = 0;

  Future<void> _processCameraFrame(CameraImage image) async {
    if (!_isCameraReady) {
      print("[SKIP] Camera not ready.");
      return;
    }

    if (_isProcessingFrame) {
      print("[SKIP] Previous frame still processing.");
      return;
    }

    if (_frameCount++ % 3 != 0) {
      print("[SKIP] Frame skipped for throttling (count: $_frameCount).");
      return;
    }

    print("[DEBUG] Processing frame $_frameCount");

    _isProcessingFrame = true;

    try {
      final rgbImage = image.format.group == ImageFormatGroup.yuv420
          ? _convertYUV420toRGB(image)
          : _convertCameraImage(image);

      print("[DEBUG] Image converted to RGB format.");

      final prediction = await _aslDetector.predict(rgbImage);
      print("[DEBUG] Prediction result: $prediction");

      if (mounted) setState(() => _currentPrediction = prediction);
    } catch (e) {
      print("[ERROR] Frame processing error: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }



  img.Image _convertCameraImage(CameraImage image) {
    try {
      print("[DEBUG] Converting image using ${image.format.group} format.");

      // For Android (YUV420 format)
      if (image.format.group == ImageFormatGroup.yuv420) {
        return img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes[0].bytes.buffer,
        );
      }
      // For iOS (BGRA8888 format)
      else {
        return img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes[0].bytes.buffer,
        );
      }

    } catch (e) {
      print("Image conversion error: $e");
      // Return blank image with proper dimensions
      return img.Image(width: image.width, height: image.height);
    }
  }
  img.Image _convertYUV420toRGB(CameraImage image) {
    print("[DEBUG] Converting image using ${image.format.group} format.");
    final width = image.width;
    final height = image.height;
    final rgbImage = img.Image(width: width, height: height);

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIndex = y * width + x;
        final uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

        final yValue = yPlane[yIndex].toDouble();
        final uValue = uPlane[uvIndex].toDouble() - 128;
        final vValue = vPlane[uvIndex].toDouble() - 128;

        // Convert YUV to RGB
        final r = (yValue + 1.402 * vValue).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * uValue - 0.714136 * vValue).clamp(0, 255).toInt();
        final b = (yValue + 1.772 * uValue).clamp(0, 255).toInt();

        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return rgbImage;
  }

  @override
  void dispose() {
    _aslCameraController.dispose();
    _aslDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("ASL Video Call")),
        body: BlocConsumer<VideoChatBloc, VideoChatState>(
            listener: (context, state) {
              if (state is VideoChatConnectionFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Connection failed: ${state.exception}")),
                );
              } else if (state is VideoChatDisconnected) {
                context.go(AppRoute.homePath);
              }
            },
            builder: (context, state) {
              if (state is VideoChatInitial || state is VideoChatConnecting) {
                return const Center(child: CircularProgressIndicator());
              }

              RtcEngine? engine;
              int? remoteUid;

              if (state is VideoChatShowRemoteUser) {
                engine = state.engine;
                remoteUid = state.remoteUid;
              } else if (state is VideoChatConnected) {
                engine = state.engine;
              }

              return Stack(
                children: [
                  // Remote video (if available)
                  if (remoteUid != null)
                    RemoteVideoWidget(
                      engine: engine!,
                      remoteUid: remoteUid!,
                      channel: ChannelNameGenerator.makeChannelName(widget.username1, widget.username2),
                    ),

                  // Local video preview
                  Positioned(
                    top: 20,
                    right: 20,
                    width: 120,
                    height: 160,
                    child: LocalVideoWidget(engine: engine!),
                  ),

                  // ASL Prediction Display
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentPrediction,
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  // End call button
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: () => context.read<VideoChatBloc>().add(VideoChatDisconnectRequested()),
                        child: const Text("END CALL", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              );
            },
        ),
      );
      }
}
