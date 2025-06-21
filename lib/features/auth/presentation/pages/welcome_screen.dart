import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Correct import for fluttertoast
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/video_chat/services/%20speech_to_text_service.dart';
import '../../../../core/constants/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../providers/language_provider.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final t = languageProvider.translate;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimaryColor, kBackgroundColor], // Adjust gradient as needed
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 500),
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: Duration(milliseconds: 500),
                    child: Image.asset(
                      'assets/icon_transparent.png',
                      width: 350,
                      height: 350,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  t('welcome'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45, // Increased font size,
                    fontFamily: kFont,
                    // fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  t('tagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: kTextPrimary, fontFamily: kFont),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _handleNavigation(context, AppRoute.signUpPath, t);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16), // Adjust button width and height
                        backgroundColor: kPrimaryColor, // Button background color
                        minimumSize:
                        Size(150, 60), // Set minimum size for width and height
                      ),
                      child: Text(
                        t('signUp'),
                        style: TextStyle(
                          color: Colors.white, // Change text color
                          fontSize: 20, // Adjust font size
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: () {
                        context.push(AppRoute.signInPath);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16), // Adjust button width and height
                        side: BorderSide(color: kTextPrimary), // Border color
                        minimumSize:
                        Size(150, 60), // Set minimum size for width and height
                      ),
                      child: Text(
                        t('signIn'),
                        style: TextStyle(
                          color: kTextPrimary, // Change text color
                          fontSize: 20, // Adjust font size
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String path, Function t) {
    String toastMessage =
    path == AppRoute.signUpPath ? t('creatingAccount') : t('accessingAccount');

    // Fluttertoast.showToast(
    //   msg: toastMessage,
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.BOTTOM,
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: Colors.black,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );

    context.push(path); // Navigate using GoRouter
  }
}

