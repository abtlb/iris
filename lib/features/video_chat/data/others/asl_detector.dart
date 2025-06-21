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

  //todo separate in different module
  var lastPrediction = '-';
  var predictionConfirmation = 0;

  Stream<String> get predictionStream => predictionController.stream;

  final List<String> _labels = [
    // 26 letters a–z
    for (var i = 0; i < 26; i++) String.fromCharCode(97 + i),
    'Hi', 'Good', 'Bad', 'how are', 'you', 'my', 'name', 'nice to', 'meet', 'you', 'what is', 'I\'m fine' , 'thanks',
  ];

  ASLDetector._privateConstructor();

  static Future<ASLDetector> initialize() async {
    var aslDetector = ASLDetector._privateConstructor();
    aslDetector.predictionController = StreamController<String>.broadcast();
    await aslDetector.loadModel();
    return aslDetector;
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/hand_model2.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      _isModelLoaded = true;

      final inputs = _interpreter.getInputTensors();
      for (var tensor in inputs) {
        print('— Input tensor —');
        print('  name : ${tensor.name}');
        print('  shape: ${tensor.shape}');
        print('  type : ${tensor.type}');
      }

      final outputs = _interpreter.getOutputTensors();
      for (var t in outputs) {
        print('— Output tensor —');
        print('  name : ${t.name}');
        print('  shape: ${t.shape}');
        print('  type : ${t.type}');
      }
    } catch (e) {
      print("Model loading error: $e");
      rethrow;
    }
  }

  /// Mirror Python’s pre_process_landmark exactly:
  Float32List normalizeLikeTrainer(List<NormalizedLandmark> lmList) {
    assert(lmList.length == 21);

    // 1) Subtract wrist (index 0)
    final baseX = lmList[0].x;
    final baseY = lmList[0].y;
    final shifted = <double>[];
    for (var lm in lmList) {
      shifted.add(lm.x - baseX);
      shifted.add(lm.y - baseY);
    }

    // 2) Find max absolute value
    final maxVal = shifted.map((v) => v.abs()).reduce(max).clamp(1e-6, double.infinity);

    // 3) Divide every element by maxVal
    final out = Float32List(shifted.length);
    for (var i = 0; i < shifted.length; i++) {
      out[i] = shifted[i] / maxVal;
    }
    return out;
  }

  String predictFromLandmarks(List<NormalizedLandmark> handLandmarks) {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded');
    }

    if (handLandmarks.length != 21) {
      throw Exception('Expected 21 landmarks, got ${handLandmarks.length}');
    }

    // Fixed: Use the same preprocessing as training data
    final input = normalizeLikeTrainer(handLandmarks);
    final input2D = [input.toList()];

    // Get output shape and allocate buffer
    final outputTensor = _interpreter.getOutputTensor(0);
    final outShape = outputTensor.shape;
    final numClasses = outShape[1];

    final output = List<List<double>>.generate(
      1,
          (_) => List.filled(numClasses, 0.0),
    );

    // Run inference
    _interpreter.run(input2D, output);

    // Get prediction (argmax)
    final scores = output[0];
    var best = 0;
    for (var c = 1; c < numClasses; c++) {
      if (scores[c] > scores[best]) best = c;
    }

    // 2) Map index to the corresponding label.
    final predictedLabel = _labels[best];

    // 3) If confidence is too low, reset and return empty:
    const accuracyThreshold = 0.95;
    if (scores[best] < accuracyThreshold) {
      // Scores are low, so we treat this as "no prediction"
      lastPrediction = ""; // reset the “last top” so we don’t count stale runs
      predictionConfirmation = 0;
      return "";
    }

    // 4) If this label matches the previous, bump the counter;
    //    otherwise, start counting anew:
    if (predictedLabel == lastPrediction) {
      predictionConfirmation++;
    } else {
      lastPrediction = predictedLabel;
      predictionConfirmation = 1;
    }

    // 5) Only when we’ve seen the same label for 5 consecutive calls do we emit:
    const confirmationThreshold = 5;
    if (predictionConfirmation != confirmationThreshold) {
      return "";
    }

    // Confirmed prediction
    predictionController.add(predictedLabel);
    return predictedLabel;
  }

  String predictFromLandmarksLearning(List<NormalizedLandmark> handLandmarks) {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded');
    }

    if (handLandmarks.length != 21) {
      throw Exception('Expected 21 landmarks, got ${handLandmarks.length}');
    }

    // Fixed: Use the same preprocessing as training data
    final input = normalizeLikeTrainer(handLandmarks);
    final input2D = [input.toList()];

    // Get output shape and allocate buffer
    final outputTensor = _interpreter.getOutputTensor(0);
    final outShape = outputTensor.shape;
    final numClasses = outShape[1];

    final output = List<List<double>>.generate(
      1,
          (_) => List.filled(numClasses, 0.0),
    );

    // Run inference
    _interpreter.run(input2D, output);

    // Get prediction (argmax)
    final scores = output[0];
    var best = 0;
    for (var c = 1; c < numClasses; c++) {
      if (scores[c] > scores[best]) best = c;
    }

    // 2) Map index to the corresponding label.
    final predictedLabel = _labels[best];

    // 3) If confidence is too low, reset and return empty:
    const accuracyThreshold = 0.95;
    if (scores[best] < accuracyThreshold) {
      // Scores are low, so we treat this as "no prediction"
      return "";
    }

    // Confirmed prediction
    predictionController.add(predictedLabel);
    return predictedLabel;
  }

  void dispose() {
    predictionController.close();
    _interpreter.close();
  }

  // Add this method to your ASLDetector class
  String testWithSample() {
    if (!_isModelLoaded) {
      throw Exception('Model not loaded');
    }

    // Your test sample from training data
    final testSample = [
      0.012624658644199371, 0.22299912571907043, 0.08063869178295135, 0.20813438296318054,
      0.1462673544883728, 0.14989569783210754, 0.17917226254940033, 0.0781145989894867,
      0.16361616551876068, 0.012773066759109497, 0.12523438036441803, 0.06765887141227722,
      0.14337031543254852, 0.031812310218811035, 0.11525624990463257, 0.08741939067840576,
      0.09421226382255554, 0.1310526430606842, 0.08503995835781097, 0.04940858483314514,
      0.10592149198055267, 0.00836879014968872, 0.08023543655872345, 0.08498582243919373,
      0.06419013440608978, 0.13916155695915222, 0.04359115660190582, 0.04055425524711609,
      0.0631527304649353, 0.0, 0.04653681814670563, 0.08424946665763855,
      0.03661532700061798, 0.14043167233467102, 0.0, 0.03954556584358215,
      0.01874162256717682, 0.013996809720993042, 0.014229685068130493, 0.07572215795516968,
      0.010736033320426941, 0.11657759547233582
    ];

    print("Testing with training sample...");
    print("Expected label: 'a'");
    print("Input length: ${testSample.length}");

    // Convert to 2D array for model input
    final input2D = [testSample];

    // Get output shape and allocate buffer
    final outputTensor = _interpreter.getOutputTensor(0);
    final outShape = outputTensor.shape;
    final numClasses = outShape[1];

    final output = List<List<double>>.generate(
      1,
          (_) => List.filled(numClasses, 0.0),
    );

    // Run inference
    _interpreter.run(input2D, output);

    // Get prediction (argmax)
    final scores = output[0];
    var best = 0;
    for (var c = 1; c < numClasses; c++) {
      if (scores[c] > scores[best]) best = c;
    }

    final predictedLabel = _labels[best];
    final confidence = scores[best];

    print("Predicted label: '$predictedLabel'");
    print("Confidence: ${confidence.toStringAsFixed(4)}");
    print("Match: ${predictedLabel == 'a' ? '✓' : '✗'}");

    // Print top 3 predictions for debugging
    print("\nTop 3 predictions:");
    final sortedIndices = List.generate(scores.length, (i) => i);
    sortedIndices.sort((a, b) => scores[b].compareTo(scores[a]));

    for (var i = 0; i < 3 && i < sortedIndices.length; i++) {
      final idx = sortedIndices[i];
      print("${i + 1}. ${_labels[idx]}: ${scores[idx].toStringAsFixed(4)}");
    }

    return predictedLabel;
  }

// Call this method to test
// Example usage in your main code:
// final result = aslDetector.testWithSample();
}