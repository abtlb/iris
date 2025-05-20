// lib/features/video_chat/services/speech_to_text_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  late stt.SpeechToText _speech;
  bool _isAvailable = false;
  bool _isListening = false;
  String recognizedText = "";

  SpeechToTextService() {
    _speech = stt.SpeechToText();
  }
  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize();
    return _isAvailable;
  }

  void startListening(Function(String) onResult) {
    if (!_isAvailable) return;
    _speech.listen(onResult: (result) {
      recognizedText = result.recognizedWords;
      onResult(recognizedText);
    });
    _isListening = true;
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }
}
