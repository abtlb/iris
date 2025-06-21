import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/styles.dart';

class TextMagnifierSpeakerScreen extends StatefulWidget {
  const TextMagnifierSpeakerScreen({super.key});

  @override
  State<TextMagnifierSpeakerScreen> createState() => _TextMagnifierSpeakerScreenState();
}

class _TextMagnifierSpeakerScreenState extends State<TextMagnifierSpeakerScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _phraseController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final ScrollController _scrollController = ScrollController();
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
    // Scroll to bottom to show the magnified text
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryColor, kBackgroundColor],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section matching home page design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 50, left: 30, right: 30, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // BACK BUTTON with white color for better contrast
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: kTextLight),
                                  onPressed: () {
                                    GoRouter.of(context).pop();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // TITLE with light color
                              Text(
                                'Text Magnifier\n& Speaker',
                                style: Styles.textStyle30.copyWith(
                                  color: kTextLight,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: kFont,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
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
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isMagnifierTab ? _buildMagnifierTab() : _buildSavedPhrasesTab(),
              ),
            ),
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
            color: isActive ? Colors.white.withOpacity(0.9) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? kPrimaryColor : kTextLight,
              fontFamily: kFont,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMagnifierTab() {
    return Column(
      children: [
        // Input and control buttons section
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(_textController, 'Enter text to magnify...'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.search,
                      label: 'Magnify',
                      onPressed: _magnifyText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.volume_up,
                      label: 'Speak',
                      onPressed: () => _speak(_textController.text),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Magnified text display - takes maximum available space
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [kPrimaryColor, kBlueLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    _textController.text.isEmpty
                        ? 'Type text above to see it magnified here...'
                        : _textController.text,
                    style: TextStyle(
                      fontSize: _textController.text.isEmpty ? 24 : _calculateFontSize(),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: kFont,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }


  double _calculateFontSize() {
    final textLength = _textController.text.length;
    if (textLength <= 10) return 120;
    if (textLength <= 20) return 80;
    if (textLength <= 50) return 60;
    if (textLength <= 100) return 50;
    return 24;
    // return mapValue(textLength.toDouble(), 0, 100, 60, 24);
  }

  Widget _buildSavedPhrasesTab() {
    return Column(
      children: [
        // Add phrase section
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(_phraseController, 'Add a new phrase...'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  label: 'Save Phrase',
                  icon: Icons.add,
                  onPressed: _savePhrase,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Saved phrases list
        Expanded(
          child: _savedPhrases.isEmpty
              ? Center(
            child: Text(
              'No saved phrases yet.\nAdd one above to get started!',
              style: TextStyle(
                fontSize: 18,
                color: kTextLight,
                fontFamily: kFont,
              ),
              textAlign: TextAlign.center,
            ),
          )
              : ListView.builder(
            itemCount: _savedPhrases.length,
            itemBuilder: (context, index) {
              final phrase = _savedPhrases[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  title: Text(
                    phrase,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kTextLight,
                      fontFamily: kFont,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: kTextLight),
                        onPressed: () => _speak(phrase),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: kTextLight),
                        onPressed: () {
                          _textController.text = phrase;
                          setState(() {
                            _isMagnifierTab = true;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: kTextLight),
                        onPressed: () => _deletePhrase(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: kFont,
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: kTextLight.withOpacity(0.7),
          fontFamily: kFont,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: kTextLight,
            width: 2,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: kTextLight,
        fontFamily: kFont,
      ),
    );
  }
}