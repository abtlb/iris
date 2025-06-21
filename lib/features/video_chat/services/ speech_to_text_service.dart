// lib/features/video_chat/services/speech_to_text_service.dart
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  static const _audioChannel = MethodChannel('app.audio_control');
  late stt.SpeechToText _speech;
  bool _isAvailable = false;
  bool _isListening = false;
  String lastRecognizedText = "897234";
  String recognizedText = "";
  Function(String)? onResult;

  SpeechToTextService() {
    _speech = stt.SpeechToText();
  }

  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize(
        onStatus: statusListener
    );
    return _isAvailable;
  }

  Future<void> startListening(Function(String) onResult) async {
    this.onResult = onResult;
    if (!_isAvailable) return;

    // 1. Mute Android "notification" stream to suppress beep
    try {
      await _audioChannel.invokeMethod('muteNotification');
    } catch (_) {
      // If this fails (e.g., on iOS or if channel not set), ignore
    }

    await _speech.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          if(recognizedText == lastRecognizedText) {
            return;
          }
          lastRecognizedText = recognizedText;
          onResult(recognizedText);
        },
        listenFor: const Duration(minutes: 10),
        localeId: 'en-US',
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,
        )
    );
    _isListening = true;
    // _speech.changePauseFor(const Duration(seconds: 3));
  }

  void statusListener(String status) {
    if (_isListening && status == "notListening") {
      if (onResult != null) {
        startListening(onResult!);
      }
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      // 3. Unmute right after listen() is called (the beep is already suppressed)
      try {
        await _audioChannel.invokeMethod('unmuteNotification');
      } catch (_) {
        // ignore on failure
      }

      await _speech.stop();
      _isListening = false;
    }
  }
}