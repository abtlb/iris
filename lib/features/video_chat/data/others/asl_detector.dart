import 'dart:async';
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:untitled3/protos/landmark.pb.dart';

class ASLDetector {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  late StreamController<String> predictionController;
  late List<List<double>> outputBuffer;
  Stream<String> get predictionStream => predictionController.stream;

  ASLDetector._privateConstructor();

  static Future<ASLDetector> initialize() async {
    var aslDetector = ASLDetector._privateConstructor();

    aslDetector.predictionController = StreamController<String>.broadcast();
    await aslDetector.loadModel();
    // aslDetector.outputBuffer = List.generate(
    //   3584,
    //       (_) => List<double>.filled(36, 0),
    // );
    return aslDetector;
  }

// Call this once at startup
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/hand_model.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      _isModelLoaded = true;
      // 2) Query the input tensor(s):
      final inputs = _interpreter.getInputTensors();
      for (var tensor in inputs) {
        print('— Input tensor —');
        print('  name : ${tensor.name}');
        print('  shape: ${tensor.shape}');   // e.g. [1,63]
        print('  type : ${tensor.type}');    // e.g. TfLiteType.float32
      }
    } catch (e) {
      print("Model loading error: $e");
      rethrow;
    }
  }

//   String predict(img.Image image) {
//     if (!_isModelLoaded) throw Exception('Model not loaded');
//
//     // 1) Preprocess
//     final inputBuffer = _preprocessImage(image);
//
//     // 2) Inspect the model’s sole output tensor
//     final outputTensor = _interpreter.getOutputTensor(0);
//     final shape = outputTensor.shape;          // e.g. [3584, 36]
//     final rows = shape[0], cols = shape[1];
//
//     // 3) Allocate a matching 2D List:
//     final outputBuffer = List.generate(
//       rows,
//           (_) => List<double>.filled(cols, 0.0),
//     );
//
//     // 4) Run inference
//     _interpreter.run(inputBuffer, outputBuffer);
//
// // 1) Sum scores for each class across all anchors
//     final totals = List<double>.filled(cols, 0.0);
//     for (var i = 0; i < rows; i++) {
//       for (var j = 0; j < cols; j++) {
//         totals[j] += outputBuffer[i][j];
//       }
//     }
// // 2) Pick the class with the highest total
//     var best = 0;
//     for (var j = 1; j < cols; j++) {
//       if (totals[j] > totals[best]) best = j;
//     }
// // 3) Map 0→'A', 1→'B', … etc.
//     final prediction = String.fromCharCode(65 + best);
//
//     predictionController.add(prediction);
//     return prediction;
//   }

  String predict(ByteBuffer landmarks) {
    if (!_isModelLoaded) throw Exception('Model not loaded');
    // 2) Inspect the model’s sole output tensor
    final outputTensor = _interpreter.getOutputTensor(0);
    final shape = outputTensor.shape;          // e.g. [3584, 36]
    final rows = shape[0], cols = shape[1];

    // 3) Allocate a matching 2D List:
    final outputBuffer = List.generate(
      rows,
          (_) => List<double>.filled(cols, 0.0),
    );

    var landmarksList = landmarks
        .asFloat32List(0, 42);

    // 4) Run inference
    _interpreter.run(landmarksList, outputBuffer);

// 1) Sum scores for each class across all anchors
    final totals = List<double>.filled(cols, 0.0);
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        totals[j] += outputBuffer[i][j];
      }
    }
// 2) Pick the class with the highest total
    var best = 0;
    for (var j = 1; j < cols; j++) {
      if (totals[j] > totals[best]) best = j;
    }
// 3) Map 0→'A', 1→'B', … etc.
    final prediction = String.fromCharCode(65 + best);

    print("ASL prediction: " + prediction);
    predictionController.add(prediction);
    return prediction;
  }

  String predictFromLandmarks(List<NormalizedLandmark> landmarks) {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded');
    }
    if (landmarks.length != 21) {
      throw Exception('Expected 21 landmarks, got ${landmarks.length}');
    }

    // 1) Inspect the model’s sole output tensor
    final outputTensor = _interpreter.getOutputTensor(0);
    final shape = outputTensor.shape;       // e.g. [3584, 36]
    final rows = shape[0], cols = shape[1];

    // 2) Allocate a matching 2D List for outputs
    final outputBuffer = List.generate(
      rows,
          (_) => List<double>.filled(cols, 0.0),
    );

    // 3) Build the 42‑length Float32List from x,y of each landmark
    final inputBuffer = Float32List(landmarks.length * 2);
    for (var i = 0; i < landmarks.length; i++) {
      inputBuffer[i * 2]     = landmarks[i].x;
      inputBuffer[i * 2 + 1] = landmarks[i].y;
    }

    // 4) Run inference
    _interpreter.run(inputBuffer, outputBuffer);

    // 5) Sum scores across anchors for each class
    final totals = List<double>.filled(cols, 0.0);
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        totals[j] += outputBuffer[i][j];
      }
    }

    // 6) Pick the class with the highest total
    var best = 0;
    for (var j = 1; j < cols; j++) {
      if (totals[j] > totals[best]) best = j;
    }

    // 7) Map 0→'A', 1→'B', … etc.
    final prediction = String.fromCharCode(65 + best);

    print("ASL prediction: $prediction");
    predictionController.add(prediction);
    return prediction;
  }


  /// Resize to 224×224 and normalize [0..1].
  Float32List _preprocessImage(img.Image src) {
    final resized = img.copyResize(src, width: 224, height: 224);
    final buffer = Float32List(1 * 224 * 224 * 3);
    var offset = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final px = resized.getPixel(x, y);
        buffer[offset++] = px.r / 255.0;
        buffer[offset++] = px.g / 255.0;
        buffer[offset++] = px.b / 255.0;
      }
    }
    return buffer;
  }

  void dispose() {
    _interpreter.close();
  }
}
