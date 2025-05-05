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
    Icons.school,      // Learning
    Icons.chat,        // Chat
    Icons.zoom_in,     // Magnify
    Icons.alarm,       // Alarm
    Icons.hearing,     // Sound Detection
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12), // أبطأ دوران
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
    double radius = 140;

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية: صورة + لون أزرق بتدرج شفاف
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/wel.jpeg'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.black.withOpacity(0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            foregroundDecoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
            ),
          ),

          // الدوائر المتحركة
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
                      left: MediaQuery.of(context).size.width / 2 + offset.dx - 38,
                      top: MediaQuery.of(context).size.height / 2 + offset.dy - 38,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.blueAccent.withOpacity(0.95),
                          child: IconButton(
                            icon: Icon(icons[index], color: Colors.white, size: 30),
                            onPressed: () {
                              switch (index) {
                                case 0:
                                // عند الضغط على أيقونة Learning
                                  context.go(AppRoute.learningStart);  // توجيه إلى LearningStartScreen
                                  break;
                                case 1:
                                  context.go(
                                    AppRoute.chatHome,
                                    extra: {
                                      'senderId': 'user1',
                                      'receiverId': 'user2',
                                    },
                                  );
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
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // نص "ابدأ الآن"
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Start now',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 5,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

