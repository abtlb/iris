import 'package:flutter/material.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/util/app_route.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> icons = [
    {'icon': Icons.school, 'label': 'Learning', 'route': AppRoute.learningStart},
    {'icon': Icons.chat, 'label': 'Chat', 'route': AppRoute.chatHomePath},
    {'icon': Icons.zoom_in, 'label': 'Magnify', 'route': AppRoute.magnifierPath},
    {'icon': Icons.alarm, 'label': 'Alarm', 'route': AppRoute.alarmPath},
    {'icon': Icons.hearing, 'label': 'Sound Detection', 'route': AppRoute.soundDetection},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 250),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double radius = 150;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
              Color(0xFF90CAF9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 60),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.6),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      size: 80,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Choose your destination",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Communication easier for everyone. You will find tools and ideas to support sign language and learning.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final Size size = MediaQuery.of(context).size;
                  final double centerX = size.width / 2;
                  final double centerY = size.height / 2 + 30;

                  return Stack(
                    children: List.generate(icons.length, (index) {
                      final angle = (2 * pi / icons.length) * index + _animation.value;
                      final offset = Offset(
                        radius * cos(angle),
                        radius * sin(angle),
                      );

                      return Positioned(
                        left: centerX + offset.dx - 45,
                        top: centerY + offset.dy - 45,
                        child: GestureDetector(
                          onTap: () {
                            context.go(icons[index]['route']);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.blueAccent,
                                child: Icon(
                                  icons[index]['icon'],
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                icons[index]['label'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Start now",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
