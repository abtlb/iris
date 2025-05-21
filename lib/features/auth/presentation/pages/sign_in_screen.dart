import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_bloc.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_events.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_states.dart';
import 'package:untitled3/features/chat/presentation/pages/chat_screen_testing.dart';
import '../../../../providers/language_provider.dart';
import 'ForgotPasswordScreen.dart';
import '../../data/data_sources/remote/ApiService.dart';
import 'package:intl/intl.dart';
import 'package:untitled3/core/storage/storage.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  double titleFontSize = 30.0;
  double descriptionFontSize = 18.0;
  double buttonFontSize = 18.0;
  double textFieldFontSize = 20.0;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? errorMessage;

  void _showError(String error) {
    setState(() {
      errorMessage = error;
    });
  }

  bool validateInput(LanguageProvider languageProvider) {
    String username = _usernameController.text.trim();
    String password = _passwordController.text;

    if (username.isEmpty) {
      _showError(languageProvider.translate('usernameEmpty'));
      return false;
    }

    if (password.isEmpty) {
      _showError(languageProvider.translate('passwordEmpty'));
      return false;
    }

    if (password.length < 3) {
      _showError(languageProvider.translate('passwordTooShort'));
      return false;
    }

    return true;
  }

  void _signIn(BuildContext context, LanguageProvider languageProvider) {
    if (!validateInput(languageProvider)) return;

    setState(() {
      errorMessage = null;
    });

    BlocProvider.of<SignInBloc>(context).add(
      SignInRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: buildAppbar(languageProvider),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 130),
              Text(
                "SignChat",
                style: TextStyle(
                  fontSize: titleFontSize + 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                languageProvider.translate('signInDescription'),
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _usernameController,
                style: TextStyle(fontSize: textFieldFontSize),
                decoration: InputDecoration(
                  labelText: languageProvider.translate('Username'),
                  labelStyle: TextStyle(fontSize: textFieldFontSize, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(fontSize: textFieldFontSize),
                decoration: InputDecoration(
                  labelText: languageProvider.translate('Password'),
                  labelStyle: TextStyle(fontSize: textFieldFontSize, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              BlocConsumer<SignInBloc, SignInState>(
                listener: (context, state) {
                  if (state is SignInSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(languageProvider.translate('signInSuccess'))),
                    );
                    context.go(AppRoute.homePath);
                  } else if (state is SignInFailure) {
                    if (state.message.contains('Wrong Username or Password')) {
                      _showError(languageProvider.translate('Wrong Username or Password'));
                    } else {
                      _showError(languageProvider.translate('Wrong Username or Password'));
                    }
                  }
                },
                builder: (context, state) {
                  if (state is SignInLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: () => _signIn(context, languageProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      languageProvider.translate('signIn'),
                      style: TextStyle(fontSize: buttonFontSize, color: Colors.white),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  languageProvider.translate('forgotPassword'),
                  style: TextStyle(fontSize: descriptionFontSize, color: Colors.blue),
                ),
              ),

              // ✅ Updated Sign Up Button Here
              TextButton(
                onPressed: () {
                  context.go(AppRoute.signUpPath);
                },
                child: Text(
                  languageProvider.translate('noAccount'),
                  style: TextStyle(fontSize: descriptionFontSize, color: Colors.blue),
                ),
              ),
              TextButton( // todo: REMOVE
                onPressed: () {
                  context.go(AppRoute.learningHome);
                },
                child: Text(
                  "Learning home",
                  style: TextStyle(fontSize: descriptionFontSize, color: Colors.blue),
                ),
              ),
              TextButton( // todo: REMOVE
                onPressed: () {
                  context.go(AppRoute.soundDetection);
                },
                child: Text(
                  "Sound Detection",
                  style: TextStyle(fontSize: descriptionFontSize, color: Colors.blue),
                ),
              ),
              TextButton( // todo: REMOVE
                onPressed: () {
                  context.go(AppRoute.handTracking);
                },
                child: Text(
                  "Hand detection",
                  style: TextStyle(fontSize: descriptionFontSize, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppbar(LanguageProvider languageProvider) {
    return AppBar(
      title: Text(
        languageProvider.translate('signIn'),
        style: TextStyle(
          fontSize: titleFontSize,
          color: Colors.blue,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: languageProvider.toggleLanguage,
        ),
      ],
    );
  }
}











