import 'dart:async';

import 'package:image/image.dart' as img;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:untitled3/features/video_chat/data/others/asl_detector.dart';
import 'package:untitled3/features/video_chat/data/others/hands_service.dart';

class FrameObserver {
  final ASLDetector aslDetector;
  final Hands hands;
  bool _isProcessingFrame = false;
  int _frameCount = 1;

  FrameObserver({required this.aslDetector, required this.hands});

  /// Convert a YUV420 (I420) frame into an RGB img.Image
  img.Image yuv420ToImage(VideoFrame frame) {
    final w = frame.width!;
    final h = frame.height!;
    final out = img.Image(width: w, height: h);

    final yBuf = frame.yBuffer!;
    final uBuf = frame.uBuffer!;
    final vBuf = frame.vBuffer!;
    final yStride = frame.yStride;
    final uStride = frame.uStride;
    final vStride = frame.vStride;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final yi = y * yStride! + x;
        final ui = (y >> 1) * uStride! + (x >> 1);
        final vi = (y >> 1) * vStride! + (x >> 1);

        final Y = yBuf[yi].toInt() & 0xFF;
        final U = (uBuf[ui].toInt() & 0xFF) - 128;
        final V = (vBuf[vi].toInt() & 0xFF) - 128;

        var r = (Y + 1.402 * V).round();
        var g = (Y - 0.344136 * U - 0.714136 * V).round();
        var b = (Y + 1.772 * U).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        out.setPixelRgb(x, y, r, g, b);
      }
    }

    return out;
  }

  /// Your entry point for processing
  void receiveFrame(VideoSourceType videoSourceType, VideoFrame frame){
    //todo delete this
    // if (_frameCount++ % 10 != 0) {
    //   return;
    // }
    // final rgbImage = yuv420ToImage(frame);
    // // unawaited(_processCameraFrame(rgbImage));
    // var landmarks = hands.predict(rgbImage);
    // if (landmarks != null) {
    //   aslDetector.predict(landmarks);
    // }
  }

  Stream<String> getPredictionStream() => aslDetector.predictionStream;
}