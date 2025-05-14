import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ASLDetector {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/hand_model.tflite');
      _isModelLoaded = true;
    } catch (e) {
      print("Model loading error: $e");
      throw Exception("Model loading failed");
    }
  }

  String predict(img.Image image) {
    if (!_isModelLoaded) return "Model not loaded";

    try {
      // Create input tensor
      final input = _preprocessImage(image);
      final output = List<double>.filled(26, 0).reshape([1, 26]);

      _interpreter.run(input, output);
      return _interpretOutput(output);
    } catch (e) {
      print("Prediction error: $e");
      return "Error";
    }
  }

  List<double> _preprocessImage(img.Image image) {
    // Resize and normalize
    final resized = img.copyResize(image, width: 224, height: 224);
    final inputBuffer = Float32List(1 * 224 * 224 * 3);

    // Manual pixel processing
    var pixelIndex = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        inputBuffer[pixelIndex] = pixel.r.toDouble() / 255.0;
        inputBuffer[pixelIndex + 1] = pixel.g.toDouble() / 255.0;
        inputBuffer[pixelIndex + 2] = pixel.b.toDouble() / 255.0;
        pixelIndex += 3;
      }
    }

    return inputBuffer;
  }

  String _interpretOutput(List<dynamic> output) {
    final scores = output[0] as List<double>;
    final maxIndex = scores.indexOf(scores.reduce((a, b) => a > b ? a : b));
    return String.fromCharCode(65 + maxIndex);
  }

  void dispose() {
    _interpreter.close();
  }
}
