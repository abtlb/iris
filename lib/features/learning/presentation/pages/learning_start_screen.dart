import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/util/app_route.dart';

class LearningStartScreen extends StatefulWidget {
  const LearningStartScreen({Key? key}) : super(key: key);

  @override
  State<LearningStartScreen> createState() => _LearningStartScreenState();
}

class _LearningStartScreenState extends State<LearningStartScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/asi.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),


          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
              onPressed: () {
                GoRouter.of(context).go(AppRoute.homePath);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height / 2.88,
              width: width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
              ),
              child: Column(
                children: [
                  SizedBox(height: height * 0.07),
                  CustomText(
                    text: 'Online Learning Everywhere',
                    size: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  CustomText(
                    text: 'Learn with pleasure with',
                    size: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                  CustomText(
                    text: 'us, wherever you are',
                    size: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                  SizedBox(height: height * 0.01),
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go('/learningHome'); // الانتقال إلى الصفحة المعنية
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: height * 0.08,
                      width: width * 0.35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const CustomText(
                        text: 'Get Started',
                        size: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.size,
    required this.color,
    required this.fontWeight,
    required this.text,
  });

  final String text;
  final double size;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: size,
        color: color,
      ),
    );
  }
}

