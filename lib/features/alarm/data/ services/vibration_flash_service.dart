import 'dart:async';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:untitled3/core/constants/constants.dart';

class VibrationFlashService {
  bool _running = false;

  VibrationFlashService();

  /// Starts synchronized vibration and flash in [pattern] pulses per cycle, repeating until stopped.
  void start(int pattern) {
    if (_running) return;
    _running = true;
    _runCycle(pattern);
  }

  /// Stops both vibration and flash, canceling any ongoing operations.
  Future<void> stop() async {
    _running = false;
    await Future.wait([
      _turnFlashOff(),
      Vibration.cancel(),
    ]);
  }

  Future<void> _runCycle(int pattern) async {
    while (_running) {
      for (int i = 0; _running && i < pattern; i++) {
        // Turn both on simultaneously
        await Future.wait([
          _turnFlashOn(),
          _startVibration(),
        ]);

        // Keep both on for the trigger period
        await Future.delayed(const Duration(milliseconds: triggerOnPeriod));

        // Turn both off simultaneously
        await Future.wait([
          _turnFlashOff(),
          Vibration.cancel(),
        ]);

        // Delay between pulses (except after the last pulse in the pattern)
        if (i < pattern - 1) {
          await Future.delayed(const Duration(milliseconds: triggerOnDelay));
        }
      }

      // Delay at the end of each complete cycle
      if (_running) {
        await Future.delayed(const Duration(milliseconds: triggerCycleEnd));
      }
    }

    // Ensure everything is off when stopping
    await Future.wait([
      _turnFlashOff(),
      Vibration.cancel(),
    ]);
  }

  Future<void> _turnFlashOn() async {
    try {
      await TorchLight.enableTorch();
    } catch (e) {
      print('Error enabling flash: $e');
    }
  }

  Future<void> _turnFlashOff() async {
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print('Error disabling flash: $e');
    }
  }

  Future<void> _startVibration() async {
    try {
      // Use a long duration since we'll cancel it manually
      await Vibration.vibrate(duration: 10000);
    } catch (e) {
      print('Error starting vibration: $e');
    }
  }
}