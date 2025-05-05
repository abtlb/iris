import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/util/app_route.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<_FeatureButton> _buttons = [
    _FeatureButton(icon: Icons.school, label: 'Learning', route: AppRoute.learningHome),
    _FeatureButton(icon: Icons.chat, label: 'Chat', route: AppRoute.chatHome),
    //_FeatureButton(icon: Icons.zoom_in, label: 'Magnify', route: AppRoute.magnify),
   // _FeatureButton(icon: Icons.alarm, label: 'Alarm', route: AppRoute.alarm),
    //_FeatureButton(icon: Icons.hearing, label: 'Sound', route: AppRoute.soundDetection),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildButton(double angle, _FeatureButton button, int index) {
    final radius = 120.0;
    final x = radius * cos(angle + _animation.value * 2 * pi);
    final y = radius * sin(angle + _animation.value * 2 * pi);
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 + x - 30,
      top: MediaQuery.of(context).size.height / 2 + y - 30,
      child: GestureDetector(
        onTap: () => context.go(button.route),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueAccent,
          child: Icon(button.icon, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with opacity
          Opacity(
            opacity: 0.15,
            child: Image.asset(
              'assets/wel.jpeg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Center(
            child: Stack(
              children: List.generate(_buttons.length, (index) {
                double angle = (2 * pi / _buttons.length) * index;
                return buildButton(angle, _buttons[index], index);
              }),
            ),
          ),
          // Center logo
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.home, color: Colors.white, size: 30),
            ),
          )
        ],
      ),
    );
  }
}

class _FeatureButton {
  final IconData icon;
  final String label;
  final String route;

  _FeatureButton({required this.icon, required this.label, required this.route});
}
