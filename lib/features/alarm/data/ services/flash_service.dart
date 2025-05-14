import 'dart:async';
import 'package:torch_light/torch_light.dart';
import 'package:untitled3/core/constants/constants.dart';

class FlashService {
  bool _running = false;

  FlashService();

  void start(int pattern) {
    if (_running) return;
    _running = true;

    _runCycle(pattern);
  }

  Future<void> stop() async {
    _running = false;
    await _turnFlashOff();
  }

  Future<void> _runCycle(int pattern) async {
    for (int i = 0; _running; i = (i + 1) % pattern) {
        await _turnFlashOn();
        await Future.delayed(const Duration(milliseconds: triggerOnPeriod));
        await _turnFlashOff();
        await Future.delayed(const Duration(milliseconds: triggerOnDelay));

      if (i == pattern - 1) {
        await Future.delayed(const Duration(milliseconds: triggerCycleEnd));
      }
    }

    await _turnFlashOff();
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
}