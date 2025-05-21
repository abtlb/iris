import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';



class Hands {
  Interpreter? interpreter;
  List<List<int>> outputShapes = [];
  List<TensorType> outputTypes = [];

  Hands({this.interpreter}) {
    loadModel();
  }

  final int inputSize = 224;
  final double existThreshold = 0.1;
  final double scoreThreshold = 0.3;

  int get getAddress => interpreter!.address;
  Interpreter? get getInterpreter => interpreter;

  Hands._privateConstructor();

  static Future<Hands> initialize() async {
    var hands = Hands._privateConstructor();
    await hands.loadModel();
    return hands;
  }

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      interpreter ??= await Interpreter.fromAsset(
        'assets/models/hand_landmark.tflite',
        options: options,
      );

      // Cache output tensor shapes & types
      for (var t in interpreter!.getOutputTensors()) {
        outputShapes.add(t.shape);
        outputTypes.add(t.type);
      }
    } catch (e) {
      log('Error while creating interpreter: $e');
    }
  }

  /// Preprocess the image: rotate, flip, resize, normalize to [0..1]
  Float32List _preprocess(image_lib.Image src) {
    // Adjust for camera orientation on Android
    // if (Platform.isAndroid) {
    //   src = image_lib.copyRotate(src, angle: -90);
    //   src = image_lib.flipHorizontal(src);
    // }

    // Resize to [inputSize, inputSize]
    final resized = image_lib.copyResize(src, width: inputSize, height: inputSize);

    // Normalize pixels to [0,1]
    final bytes = Float32List(inputSize * inputSize * 3);
    int idx = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        bytes[idx++] = pixel.r / 255.0;
        bytes[idx++] = pixel.g / 255.0;
        bytes[idx++] = pixel.b / 255.0;
      }
    }
    return bytes;
  }

  /// Runs the hand-landmark model and returns 21 (x,y) Offsets or null
  ByteBuffer? predict(image_lib.Image image) {
    if (interpreter == null) return null;

    // 1) Preprocess
    final inputBuffer = _preprocess(image);
    // Model expects input shape [1,224,224,3]
    final shapedInput = inputBuffer.buffer;

    // 2) Allocate output buffers based on cached shapes
    // outputShapes[0] -> landmarks, e.g. [1,63]
    final outShape0 = outputShapes[0];
    final outLen0 = outShape0.reduce((a, b) => a * b);
    final outputLandmarks = Float32List(outLen0);

    // outputShapes[1] -> exist flag, e.g. [1,1]
    final outShape1 = outputShapes[1];
    final outLen1 = outShape1.reduce((a, b) => a * b);
    final outputExist = Float32List(outLen1);

    // outputShapes[2] -> score, e.g. [1,1]
    final outShape2 = outputShapes[2];
    final outLen2 = outShape2.reduce((a, b) => a * b);
    final outputScores = Float32List(outLen2);

    // 3) Run inference
    final inputs = <Object>[shapedInput];
    final outputs = <int, Object>{
      0: outputLandmarks.buffer,
      1: outputExist.buffer,
      2: outputScores.buffer,
    };
    interpreter!.runForMultipleInputs(inputs, outputs);

    // 4) Apply thresholds
    if (outputExist[0] < existThreshold || outputScores[0] < scoreThreshold) {
      print("no landmarks");
      return null;
    }

    // 5) Convert landmark list [x0,y0,z0,...] to List<Offset>
    final landmarkResults = <Offset>[];
    // Assume outShape0 = [1,63] or [63]
    for (int i = 0; i < outLen0; i += 3) {
      final nx = outputLandmarks[i];
      final ny = outputLandmarks[i + 1];
      // z = outputLandmarks[i + 2];  // if needed
      // Map normalized [0..1] to original image coords:
      final dx = nx * image.width;
      final dy = ny * image.height;
      landmarkResults.add(Offset(dx, dy));
    }

    print('points: ' + landmarkResults.toString());
    return outputLandmarks.buffer;
  }
}