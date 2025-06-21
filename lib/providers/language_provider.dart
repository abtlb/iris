import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = 'en';

  String get language => _language;

  void setLanguage(String newLanguage) {
    if (_language != newLanguage) {
      _language = newLanguage;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _language = (_language == 'en') ? 'ar' : 'en';
    notifyListeners();
  }

  String translate(String key) {
    final translations = {
      'en': {
        'welcome': 'Welcome to IRIS',
        'tagline': 'Breaking communication barriers',
        'description': 'Connect, communicate, and share with the deaf and hard-of-hearing community',
        'signIn': 'Sign In',
        'signInDescription': 'Welcome back! Sign in to your account',
        'signUp': 'Sign Up',
        'signUpDescription': 'Please fill in the details to create an account.',
        'Name': 'Name',
        'Email': 'Email',
        'Password': 'Password',
        'confirmPassword': 'Confirm Password',
        'haveAccount': 'Already have an account? Sign In',
        'noAccount': 'Don’t have an account? Sign Up',
        'forgotPassword': 'Forgot Password?',
        'forgotPasswordDescription': 'Enter your email to receive a password reset link',
        'sendResetLink': 'Send Reset Link',
        'rememberPassword': 'Remembered your password? Sign In',
        'switchToArabic': 'عربي',
        'switchToEnglish': 'English',
        'wrongCredentials': 'Incorrect username or password',  // ✅ Added key
      },
      'ar': {
        'welcome': 'مرحباً بكم في SignChat',
        'tagline': 'كسر حواجز التواصل',
        'description': 'تواصل وشارك مع مجتمع الصم وضعاف السمع',
        'signIn': 'تسجيل الدخول',
        'signInDescription': 'مرحبًا بعودتك! سجل الدخول إلى حسابك',
        'signUp': 'إنشاء حساب',
        'signUpDescription': 'يرجى ملء التفاصيل لإنشاء حساب.',
        'Name': 'الاسم',
        'Email': 'البريد الإلكتروني',
        'Password': 'كلمة المرور',
        'confirmPassword': 'تأكيد كلمة المرور',
        'haveAccount': 'هل لديك حساب؟ تسجيل الدخول',
        'noAccount': 'ليس لديك حساب؟ سجل',
        'forgotPassword': 'نسيت كلمة المرور',
        'forgotPasswordDescription': 'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور',
        'sendResetLink': 'إرسال رابط إعادة التعيين',
        'rememberPassword': 'تذكرت كلمة المرور؟ تسجيل الدخول',
        'switchToArabic': 'عربي',
        'switchToEnglish': 'English',
        'wrongCredentials': 'اسم المستخدم أو كلمة المرور غير صحيحة', // ✅ Added key
      },
    };

    return translations[_language]?[key] ?? key;
  }
}



