import 'package:flutter/services.dart';

class SymSpellChannel {
  static const MethodChannel _channel =
  MethodChannel('com.example.symspell/bridge');

  /// Corrects the given [word] using the SymSpell native bridge.
  static Future<String> correct(String word) async {
    try {
      final String? corrected = await _channel.invokeMethod<String>(
        'correct',
        {'word': word},
      );
      return corrected ?? word;
    } on PlatformException catch (e) {
      // In case of error, return original word
      print('SymSpell error: ${e.message}');
      return word;
    }
  }
}