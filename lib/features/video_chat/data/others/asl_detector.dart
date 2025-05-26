import 'dart:async';
import 'dart:math';
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

  final List<String> _labels = [
    // 26 letters a–z
    for (var i = 0; i < 26; i++) String.fromCharCode(97 + i),
    // + 4 extra words (to total 30)
    'hello', 'how', 'you', 'thanks',
  ];



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
        'assets/models/hand_model2.tflite',
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
        final outputs = _interpreter.getOutputTensors();
        for (var t in outputs) {
          print('— Output tensor —');
          print('  name : ${t.name}');
          print('  shape: ${t.shape}');
          print('  type : ${t.type}');
        }
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

    // 1) Normalize landmarks to Float32List
    final input = landmarks.asFloat32List(0, 42);

    // 2) Query the single output tensor to get its shape (e.g. [1,30])
    final outTensor = _interpreter.getOutputTensor(0);
    final shape = outTensor.shape;      // [1, N]
    final numClasses = shape[1];        // N = 30

    // 3) Allocate a flat Float32List of length N
    final outputBuffer = Float32List(numClasses);

    // 4) Run inference
    _interpreter.run(input, outputBuffer);

    // 5) Argmax
    var best = 0;
    for (var i = 1; i < numClasses; i++) {
      if (outputBuffer[i] > outputBuffer[best]) best = i;
    }

    // 6) Map 0→'a', …, 25→'z', 26→'hello', …etc.
    final prediction = _labels[best];
    predictionController.add(prediction);
    return prediction;
  }

  /// Takes a list of 21 NormalizedLandmark (each in [0…1] relative to image),
  /// re‐normalizes them to [0…1] over their own bounding box.
  Float32List normalizeMinMax(List<NormalizedLandmark> lmList) {
    // Extract x,y into lists
    final xs = lmList.map((lm) => lm.x).toList();
    final ys = lmList.map((lm) => lm.y).toList();

    final minX = xs.reduce(min);
    final maxX = xs.reduce(max);
    final minY = ys.reduce(min);
    final maxY = ys.reduce(max);

    final spanX = (maxX - minX).clamp(1e-6, double.infinity);
    final spanY = (maxY - minY).clamp(1e-6, double.infinity);

    // Flatten into [x0',y0', x1',y1', …] where x' = (x-minX)/spanX
    final out = Float32List(42);
    for (var i = 0; i < lmList.length; i++) {
      out[i * 2]     = (lmList[i].x - minX) / spanX;
      out[i * 2 + 1] = (lmList[i].y - minY) / spanY;
    }
    return out;
  }

  // List<double> _normalize(List<NormalizedLandmark> lmList) {
  //   // extract x’s and y’s
  //   final xs = lmList.map((lm) => lm.x).toList();
  //   final ys = lmList.map((lm) => lm.y).toList();
  //
  //   final minX = xs.reduce((a, b) => a < b ? a : b);
  //   final minY = ys.reduce((a, b) => a < b ? a : b);
  //
  //   // subtract mins and flatten
  //   final data = <double>[];
  //   for (var lm in lmList) {
  //     data.add(lm.x - minX);
  //     data.add(lm.y - minY);
  //   }
  //
  //   return data;
  // }

  /// Centers all landmarks at the wrist (index 0), and optionally scales.
  Float32List normalizeWristOrigin(List<NormalizedLandmark> lmList) {
    final wrist = lmList[0];
    // You can also compute a scale factor (e.g. distance between wrist and middle‐finger tip)
    // final scale = (lmList[12].x - wrist.x).abs().clamp(1e-6, double.infinity);

    final out = Float32List(42);
    for (var i = 0; i < lmList.length; i++) {
      out[i * 2]     = lmList[i].x - wrist.x;
      out[i * 2 + 1] = lmList[i].y - wrist.y;
      // if scaling:  / scale
    }
    return out;
  }

  Float32List toNormCoords(List<NormalizedLandmark> lmList) {
    final vals = Float32List(lmList.length * 2);
    for (var i = 0; i < lmList.length; i++) {
      vals[i * 2]     = lmList[i].x;
      vals[i * 2 + 1] = lmList[i].y;
    }
    return vals;
  }

  Float32List toPixelCoords(
      List<NormalizedLandmark> lmList,
      int imgWidth,
      int imgHeight,
      ) {
    final vals = Float32List(lmList.length * 2);
    for (var i = 0; i < lmList.length; i++) {
      vals[i * 2]     = lmList[i].x * imgWidth;
      vals[i * 2 + 1] = lmList[i].y * imgHeight;
    }
    return vals;
  }

  Float32List normalizeLikePython(List<NormalizedLandmark> lmList) {
    // 1) Gather all x's and y's
    final xs = lmList.map((lm) => lm.x).toList();
    final ys = lmList.map((lm) => lm.y).toList();
    final minX = xs.reduce(min);
    final minY = ys.reduce(min);

    // 2) Build the [1×42] flattened buffer
    final out = Float32List(21 * 2);
    for (var i = 0; i < lmList.length; i++) {
      out[i * 2]     = lmList[i].x - minX;
      out[i * 2 + 1] = lmList[i].y - minY;
    }
    return out;
  }




  String predictFromLandmarks(List<NormalizedLandmark> handLandmarks) {
    if (!_isModelLoaded) throw Exception('Model not loaded');
    if (handLandmarks.length != 21)
      throw Exception('Expected 21 landmarks, got ${handLandmarks.length}');

    // 1) Build flat input (42 values) exactly like your Python training:
    final xs = handLandmarks.map((lm) => lm.x).toList();
    final ys = handLandmarks.map((lm) => lm.y).toList();
    final minX = xs.reduce(min), minY = ys.reduce(min);

    final flatInput = Float32List(21 * 2);
    for (var i = 0; i < 21; i++) {
      flatInput[i * 2]     = handLandmarks[i].x - minX;
      flatInput[i * 2 + 1] = handLandmarks[i].y - minY;
    }

    // 2) Discover your model’s output shape ([1, 30]):
    final outShape    = _interpreter.getOutputTensor(0).shape;
    final numClasses = outShape[1]; // should be 30

    // 3) Allocate a flat output buffer of length 30
    final flatOutput = Float32List(numClasses);

    // 4) Run inference, giving TFLite both flat input and flat output:
    _interpreter.runForMultipleInputs(
        [flatInput],      // list of 1 input tensor
        { 0: flatOutput } // map output index → flat buffer
    );

    // 5) Argmax over flatOutput:
    var best = 0;
    for (var i = 1; i < numClasses; i++) {
      if (flatOutput[i] > flatOutput[best]) best = i;
    }

    // 6) Map to your 30-element label list:
    final predictedLabel = _labels[best];
    predictionController.add(predictedLabel);

    print('Predicted [$best]→$predictedLabel (scores: ${flatOutput.toList()})');
    return predictedLabel;
  }


  void dispose() {
    _interpreter.close();
  }
}
