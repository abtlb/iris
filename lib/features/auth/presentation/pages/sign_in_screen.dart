import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_bloc.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_events.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_states.dart';
import '../../../../providers/language_provider.dart';
import 'ForgotPasswordScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage;

  void _showError(String error) {
    setState(() {
      errorMessage = error;
    });
  }

  bool validateInput(LanguageProvider languageProvider) {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

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

    BlocProvider.of<SignInBloc>(context).add(SignInRequested(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.translate('signIn'),
          style: const TextStyle(color: Colors.blue),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: languageProvider.toggleLanguage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 130),
              const Text(
                "SignChat",
                style: TextStyle(
                    fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 20),
              Text(
                languageProvider.translate('signInDescription'),
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('Username'),
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('Password'),
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              BlocConsumer<SignInBloc, SignInState>(
                listener: (context, state) {
                  if (state is SignInSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(languageProvider.translate('signInSuccess'))),
                    );
                    context.go(AppRoute.homePath); // ✅ الانتقال إلى الصفحة الرئيسية بعد تسجيل الدخول الناجح
                  } else if (state is SignInFailure) {
                    _showError(languageProvider.translate('Wrong Username or Password'));
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
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.push(AppRoute.forgetPasswordPath),
                child: Text(
                  languageProvider.translate('forgotPassword'),
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoute.signUpPath),
                child: Text(
                  languageProvider.translate('noAccount'),
                  style: const TextStyle(color: Colors.blue),
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
}







