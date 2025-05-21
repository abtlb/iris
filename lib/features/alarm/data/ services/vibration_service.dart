import 'dart:async';

import 'package:vibration/vibration.dart';
import 'package:untitled3/core/constants/constants.dart';

class VibrationService {
  bool _running = false;

  VibrationService();

  /// Starts vibrating in [pattern] pulses per cycle, repeating until stopped.
  void start(int pattern) {
    if (_running) return;
    _running = true;
    _runCycle(pattern);
  }

  /// Stops any ongoing vibration and cancels the loop.
  Future<void> stop() async {
    _running = false;
    await Vibration.cancel(); // ensure we stop
  }

  Future<void> _runCycle(int pattern) async {
    // Check if device actually supports vibration
    // final hasVibrator = await Vibration.hasVibrator() ?? false;
    // if (!hasVibrator) return;

    while (_running) {
      for (int i = 0; _running; i = (i + 1) % pattern) {
        await Vibration.vibrate(duration: 10000);
        await Future.delayed(const Duration(milliseconds: triggerOnPeriod));
        await Vibration.cancel();
        await Future.delayed(const Duration(milliseconds: triggerOnDelay));

        if (i == pattern - 1) {
          await Future.delayed(
            const Duration(milliseconds: triggerCycleEnd),
          );
        }
      }
    }


    await Vibration.cancel();
  }
}
