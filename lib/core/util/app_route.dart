import 'package:go_router/go_router.dart';
import 'package:untitled3/features/auth/presentation/pages/ForgotPasswordScreen.dart';
import 'package:untitled3/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:untitled3/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:untitled3/features/auth/presentation/pages/welcome_screen.dart';
import 'package:untitled3/features/chat/presentation/pages/chat_screen_testing.dart';
import 'package:untitled3/features/chat/presentation/views/chat_view.dart';
import 'package:untitled3/features/learning/presentation/pages/learning_home.dart';
import 'package:untitled3/features/learning/presentation/pages/learning_start_screen.dart';
import 'package:untitled3/features/sound_detection/presentation/pages/sound_monitor_page.dart';
import 'package:untitled3/features/video_home/presentation/views/home_view.dart';
import 'package:untitled3/features/search/presentation/views/search_view.dart';
import 'package:untitled3/features/video_chat/presentation/pages/VideoChatTest.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/help_screen.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/account_page.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/TextMagnifierSpeakerScreen.dart';

abstract class AppRoute {
  static String welcomePath = '/';
  static String homePath = '/video_home';
  static String kChatPath = '/ChatView';
  static String kSearchPath = '/SearchView';
  static String signInPath = '/signin';
  static String signUpPath = '/signup';
  static String forgetPasswordPath = '/forgot_password';
  static String chatTestPath = '/chat_test';
  static String videoChatTestPath = '/video_test';
  static String helpPath = '/help';
  static String accountPath = '/account';
  static String magnifierPath = '/magnifier';
  static String learningHome = '/learningHome';
  static String learningStart = '/learningStart';
  static String soundDetection = '/soundDetection';

  // ✅ نضيف هذه لوظائف الأزرار في home_page.dart:
  static String chatHome = kChatPath;
  static String magnify = magnifierPath;
  static String alarm = helpPath;

  static final router = GoRouter(
    routes: [
      GoRoute(path: welcomePath, builder: (_, __) => WelcomeScreen()),
      GoRoute(path: homePath, builder: (_, __) => const HomeView()),
      GoRoute(path: kChatPath, builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ChatView(
          senderId: extra['senderId'],
          receiverId: extra['receiverId'],
        );
      }),
      GoRoute(path: kSearchPath, builder: (_, __) => const SearchView()),
      GoRoute(path: signInPath, builder: (_, __) => const SignInScreen()),
      GoRoute(path: signUpPath, builder: (_, __) => const SignUpScreen()),
      GoRoute(path: forgetPasswordPath, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: chatTestPath, builder: (_, __) => const ChatTestScreen()),
      GoRoute(
        path: videoChatTestPath,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VideoChatTestPage(
            username1: extra['username1'],
            username2: extra['username2'],
          );
        },
      ),
      GoRoute(path: helpPath, builder: (_, __) => const HelpScreen()),
      GoRoute(path: accountPath, builder: (_, __) => const AccountPage()),
      GoRoute(path: learningHome, builder: (_, __) => const LearningHome()),
      GoRoute(path: learningStart, builder: (_, __) => const LearningStartScreen()),
      GoRoute(path: magnifierPath, builder: (_, __) => const TextMagnifierSpeakerScreen()),
      GoRoute(path: soundDetection, builder: (_, __) => const SoundMonitorPage()),
    ],
  );
}





