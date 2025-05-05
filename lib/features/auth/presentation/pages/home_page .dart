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

  final List<IconData> icons = [
    Icons.school,          // Learning
    Icons.chat,            // Chat
    Icons.zoom_in,         // Magnify
    Icons.alarm,           // Alarm
    Icons.hearing,         // Sound Detection
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double radius = 100;

    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/wel.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: List.generate(icons.length, (index) {
                    final angle = (2 * pi / icons.length) * index + (_controller.value * 2 * pi);
                    final offset = Offset(
                      radius * cos(angle),
                      radius * sin(angle),
                    );
                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 + offset.dx - 25,
                      top: MediaQuery.of(context).size.height / 2 + offset.dy - 25,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blueAccent,
                        child: IconButton(
                          icon: Icon(icons[index], color: Colors.white),
                          onPressed: () {
                            switch (index) {
                              case 0:
                                context.go(AppRoute.learningHome);
                                break;
                              case 1:
                                context.go(AppRoute.chatHome);
                                break;
                              case 2:
                                context.go(AppRoute.magnify);
                                break;
                              case 3:
                                context.go(AppRoute.alarm);
                                break;
                              case 4:
                                context.go(AppRoute.soundDetection);
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Start',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}