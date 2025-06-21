import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_up/sign_up_bloc.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_up/sign_up_events.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_up/sign_up_states.dart';
import '../../../../providers/language_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_validateInputs()) {
      return;
    }

    final DateFormat inputFormat = DateFormat("M/d/yyyy");
    final DateTime parsedDate = inputFormat.parse(_dateOfBirthController.text);

    BlocProvider.of<SignUpBloc>(context).add(
      SignUpRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        email: _emailController.text,
        dateOfBirth: parsedDate,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      ),
    );
  }

  bool _validateInputs() {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String username = _usernameController.text.trim();
    String dateOfBirth = _dateOfBirthController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (firstName.isEmpty) {
      _showError('First name cannot be empty.');
      return false;
    }
    if (lastName.isEmpty) {
      _showError('Last name cannot be empty.');
      return false;
    }
    if (username.isEmpty) {
      _showError('Username cannot be empty.');
      return false;
    }
    if (dateOfBirth.isEmpty) {
      _showError('Date of birth cannot be empty.');
      return false;
    }
    if (email.isEmpty) {
      _showError('Email cannot be empty.');
      return false;
    } else if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address.');
      return false;
    }
    if (password.isEmpty) {
      _showError('Password cannot be empty.');
      return false;
    }
    if (password.length < 3) {
      _showError('Password length cannot be less than 3.');
      return false;
    }
    return true;
  }

  void _showError(String error) {
    setState(() {
      _errorMessage = error;
    });
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegExp.hasMatch(email);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat.yMd().format(pickedDate);
      _dateOfBirthController.text = formattedDate;
    }
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

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
        child: Padding(
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
                const SizedBox(height: 50),
                Text(
                  "IRIS",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: kTextLight,
                    fontFamily: kFont,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  languageProvider.translate('signUpDescription') ?? 'Create your account',
                  style: TextStyle(fontSize: 18, color: kTextLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  cursorColor: kTextPrimary,
                  decoration: _buildInputDecoration(languageProvider.translate('Username')),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _firstNameController,
                  cursorColor: kTextPrimary,
                  decoration: _buildInputDecoration(languageProvider.translate('First Name')),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _lastNameController,
                  cursorColor: kTextPrimary,
                  decoration: _buildInputDecoration(languageProvider.translate('Last Name')),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  cursorColor: kTextPrimary,
                  decoration: _buildInputDecoration(languageProvider.translate('Email')),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  cursorColor: kTextPrimary,
                  decoration: _buildInputDecoration(languageProvider.translate('Password')),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _dateOfBirthController,
                  readOnly: true,
                  cursorColor: kTextPrimary,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: const TextStyle(color: kTextPrimary),
                    suffixIcon: Icon(Icons.calendar_today, color: kTextPrimary),
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
                if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: kErrorColor)),
                const SizedBox(height: 10),
                BlocConsumer<SignUpBloc, SignUpState>(
                  listener: (context, state) {
                    if (state is SignUpSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Account created successfully!"), backgroundColor: kSuccessColor),
                      );
                      context.push(AppRoute.signInPath);
                    } else if (state is SignUpFailure) {
                      setState(() {
                        _errorMessage = state.message;
                      });
                    }
                  },
                  builder: (context, state) {
                    if (state is SignUpLoading) {
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        strokeWidth: 3.0,
                        backgroundColor: kBackgroundColor,
                      );
                    }
                    return ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        backgroundColor: kPrimaryColor,
                      ),
                      child: Text(
                        languageProvider.translate('signUp'),
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.push(AppRoute.signInPath),
                  child: Text(
                    languageProvider.translate('haveAccount'),
                    style: const TextStyle(color: kTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}