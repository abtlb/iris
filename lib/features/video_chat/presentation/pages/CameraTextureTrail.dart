// File: lib/camera_mediapipe_widget.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnLandmarksDetected = void Function(Map<String, dynamic> data);

class CameraMediaPipeWidget extends StatefulWidget {
  final ResolutionPreset resolution;
  final CameraLensDirection lensDirection;
  final OnLandmarksDetected? onLandmarksDetected;

  const CameraMediaPipeWidget({
    Key? key,
    this.resolution = ResolutionPreset.medium,
    this.lensDirection = CameraLensDirection.back,
    this.onLandmarksDetected,
  }) : super(key: key);

  @override
  _CameraMediaPipeWidgetState createState() => _CameraMediaPipeWidgetState();
}

class _CameraMediaPipeWidgetState extends State<CameraMediaPipeWidget> {
  late CameraController _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isProcessing = false;

  MethodChannel? _frameChannel;
  EventChannel? _landmarkChannel;
  StreamSubscription<dynamic>? _landmarkSubscription;

  // Will become non-null once the AndroidView is created.
  int? _pluginViewId;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Called by the parent when Flutter’s AndroidView has been created.
  void setPluginViewId(int viewId) {
    _pluginViewId = viewId;
    _setupChannelsAndStartStream();
  }

  void _setupChannelsAndStartStream() {
    if (_pluginViewId == null || !_isInitialized) return;

    // 1) Create the MethodChannel for sending frames.
    _frameChannel = MethodChannel(
        'plugins.zhzh.xyz/flutter_hand_tracking_plugin/$_pluginViewId/frames');

    // 2) Create the EventChannel for receiving landmarks.
    _landmarkChannel = EventChannel(
        'plugins.zhzh.xyz/flutter_hand_tracking_plugin/$_pluginViewId/landmarks');

    // 3) Listen for landmark bytes and decode them.
    _landmarkSubscription =
        _landmarkChannel!.receiveBroadcastStream().listen((data) {
          if (data != null && widget.onLandmarksDetected != null) {
            _handleLandmarkData(data);
          }
        }, onError: (error) {
          debugPrint('Landmark stream error: $error');
        });

    // 4) Send the frameSize (width/height) before streaming.
    final size = _controller.value.previewSize!;
    _frameChannel!
        .invokeMethod('setFrameSize', {'width': size.width.toInt(), 'height': size.height.toInt()})
        .then((_) {
      // 5) Now that the native side knows the incoming frame size, start streaming.
      _controller.startImageStream(_processCameraFrame);
    }).catchError((e) {
      debugPrint('Error sending frameSize: $e');
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
              (c) => c.lensDirection == widget.lensDirection,
          orElse: () => cameras.first);

      _controller = CameraController(
        camera,
        widget.resolution,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await _controller.initialize();
      if (_isDisposed) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Camera error: ${e.toString()}')));
      }
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessing || _frameChannel == null) return;
    _isProcessing = true;

    try {
      final bytes = await _convertCameraImageToRgbBytes(image);
      await _frameChannel!.invokeMethod('processFrame', {
        'frameData': bytes,
        'width': image.width,
        'height': image.height,
        'rotation': _computeRotation(),
      });
    } catch (e) {
      debugPrint("Frame processing error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<Uint8List> _convertCameraImageToRgbBytes(CameraImage image) async {
    if (Platform.isAndroid) {
      return _yuv420ToRgb(image);
    } else {
      // On iOS, CameraImage comes in BGRA, so we can just use plane[0].
      return image.planes[0].bytes;
    }
  }

  Uint8List _yuv420ToRgb(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final yRowStride = image.planes[0].bytesPerRow;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel!;

    final rgb = Uint8List(width * height * 3);
    int rgbIndex = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yRowStride + x;
        final uvIndex =
            (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yValue = (yPlane[yIndex] & 0xFF);
        final uValue = (uPlane[uvIndex] & 0xFF);
        final vValue = (vPlane[uvIndex] & 0xFF);

        // Standard YUV → RGB
        int r = (yValue + 1.370705 * (vValue - 128)).round();
        int g = (yValue - 0.698001 * (vValue - 128) - 0.337633 * (uValue - 128)).round();
        int b = (yValue + 1.732446 * (uValue - 128)).round();

        // Clamp
        if (r < 0) r = 0;
        else if (r > 255) r = 255;
        if (g < 0) g = 0;
        else if (g > 255) g = 255;
        if (b < 0) b = 0;
        else if (b > 255) b = 255;

        rgb[rgbIndex++] = r;
        rgb[rgbIndex++] = g;
        rgb[rgbIndex++] = b;
      }
    }
    return rgb;
  }

  int _computeRotation() {
    final orientation = MediaQuery.of(context).orientation;
    final sensorOrientation = _controller.description.sensorOrientation;
    if (orientation == Orientation.portrait) {
      return sensorOrientation;
    } else {
      return (sensorOrientation + 90) % 360;
    }
  }

  void _handleLandmarkData(dynamic data) {
    // “data” is raw ProtoBuf bytes from MediaPipe’s hand_landmarks stream.
    // You must parse these using whatever .proto definitions you’ve bundled.
    // For now, we’ll just notify the listener that new bytes arrived.
    widget.onLandmarksDetected?.call({
      'rawLandmarkBytes': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _landmarkSubscription?.cancel();
    if (_isInitialized) {
      _controller.stopImageStream();
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller),
          // The transparent PlatformView sits on top and shows MediaPipe’s output.
          AndroidView(
            viewType: 'plugins.zhzh.xyz/flutter_hand_tracking_plugin',
            layoutDirection: TextDirection.ltr,
            creationParams: <String, dynamic>{},
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (int id) {
              setPluginViewId(id);
            },
          ),
          if (_isProcessing)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Processing…',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
