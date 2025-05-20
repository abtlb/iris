import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart'; // أضف هذا
import 'package:untitled3/core/util/app_route.dart';

class TextMagnifierSpeakerScreen extends StatefulWidget {
  const TextMagnifierSpeakerScreen({super.key});

  @override
  State<TextMagnifierSpeakerScreen> createState() => _TextMagnifierSpeakerScreenState();
}

class _TextMagnifierSpeakerScreenState extends State<TextMagnifierSpeakerScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _phraseController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  List<String> _savedPhrases = [];
  bool _isMagnifierTab = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPhrases();
  }

  Future<void> _loadSavedPhrases() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPhrases = prefs.getStringList('savedPhrases') ?? [];
    });
  }

  Future<void> _savePhrasesToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedPhrases', _savedPhrases);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  void _savePhrase() {
    if (_phraseController.text.trim().isNotEmpty) {
      setState(() {
        _savedPhrases.add(_phraseController.text.trim());
        _phraseController.clear();
      });
      _savePhrasesToPrefs();
    }
  }

  void _deletePhrase(int index) {
    setState(() {
      _savedPhrases.removeAt(index);
    });
    _savePhrasesToPrefs();
  }

  void _magnifyText() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F0FF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.indigo),
          onPressed: () {
            GoRouter.of(context).go(AppRoute.homePath);// أو context.go(AppRoute.home) لو معرف المسار في AppRoute
          },
        ),
        title: const Text(
          'Text Magnifier & Speaker',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  _buildTabButton('Magnifier', _isMagnifierTab, () {
                    setState(() {
                      _isMagnifierTab = true;
                    });
                  }),
                  _buildTabButton('Saved Phrases', !_isMagnifierTab, () {
                    setState(() {
                      _isMagnifierTab = false;
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isMagnifierTab ? _buildMagnifierTab() : _buildSavedPhrasesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.indigo : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMagnifierTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(_textController, 'Enter text...'),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildSmallButton(
                icon: Icons.search,
                onPressed: _magnifyText,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildSmallButton(
                icon: Icons.volume_up,
                onPressed: () => _speak(_textController.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.indigo, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                _textController.text,
                style: const TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedPhrasesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextField(_phraseController, 'Add a new phrase...'),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _buildButton(
            label: 'Save Phrase',
            icon: Icons.add,
            onPressed: _savePhrase,
          ),
        ),
        const SizedBox(height: 10),
        ..._savedPhrases.asMap().entries.map((entry) {
          final index = entry.key;
          final phrase = entry.value;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    phrase,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.indigo),
                  onPressed: () => _speak(phrase),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.indigo),
                  onPressed: () {
                    _textController.text = phrase;
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.indigo),
                  onPressed: () => _deletePhrase(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildSmallButton({required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 24, color: Colors.white),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 18),
    );
  }
}












