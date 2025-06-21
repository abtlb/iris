import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/alarm/data/%20services/alarm_callback_service.dart';
import 'package:untitled3/features/alarm/domain/entities/alarm_entity.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_bloc.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_events.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_states.dart';
import '../../../../core/services/sym_spell_channel.dart';
import '../../../../providers/language_provider.dart';
import '../../../video_chat/services/ speech_to_text_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _spellingController = TextEditingController();
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
      _showError('Username required');
      return false;
    }

    if (password.isEmpty) {
      _showError(languageProvider.translate('Password required'));
      return false;
    }

    if (password.length < 3) {
      _showError(languageProvider.translate('Password too short'));
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
      body:
    Container(
    width: double.infinity,
    height: double.infinity,
    decoration: const BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kPrimaryColor, kBackgroundColor], // Adjust gradient as needed
    ),
    ),
    child:
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => GoRouter.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 130),
              Text(
                "IRIS",
                style: TextStyle(
                    fontSize: 40, fontWeight: FontWeight.bold, color: kTextLight, fontFamily: kFont),
              ),
              const SizedBox(height: 20),
              Text(
                languageProvider.translate('signInDescription'),
                style: TextStyle(fontSize: 18, color: kTextLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                obscureText: true,
                cursorColor: kTextPrimary,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('Username'),
                  labelStyle: const TextStyle(color: kTextPrimary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kTextPrimary, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kBorderColor, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kTextPrimary, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kErrorColor, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kErrorColor, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                cursorColor: kTextPrimary,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('Password'),
                  labelStyle: const TextStyle(color: kTextPrimary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kTextPrimary, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kBorderColor, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kTextPrimary, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kErrorColor, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: kErrorColor, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: kErrorColor)),
              const SizedBox(height: 10),
              BlocConsumer<SignInBloc, SignInState>(
                listener: (context, state) {
                  if (state is SignInSuccess) {
                    context.go(AppRoute.homePath);
                  } else if (state is SignInFailure) {
                    _showError(languageProvider.translate('Wrong Username or Password'));
                  }
                },
                builder: (context, state) {
                  if (state is SignInLoading) {
                    return CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      strokeWidth: 3.0,
                      backgroundColor: kBackgroundColor,
                    );
                  }
                  return ElevatedButton(
                    onPressed: () => _signIn(context, languageProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      backgroundColor: kPrimaryColor,
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
                  style: const TextStyle(color: kTextPrimary),
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoute.signUpPath),
                child: Text(
                  languageProvider.translate('noAccount'),
                  style: const TextStyle(color: kTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}







