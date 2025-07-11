import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/features/auth/presentation/pages/ForgotPasswordScreen.dart';
import 'package:untitled3/features/home/presentation/pages/home_page%20.dart';
import 'package:untitled3/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:untitled3/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:untitled3/features/auth/presentation/pages/welcome_screen.dart';
import 'package:untitled3/features/chat/presentation/pages/chat_screen_testing.dart';
import 'package:untitled3/features/chat/presentation/views/chat_view.dart';
import 'package:untitled3/features/learning/domain/entities/course.dart';
import 'package:untitled3/features/learning/presentation/pages/learning_home.dart';
import 'package:untitled3/features/learning/presentation/pages/learning_start_screen.dart';
import 'package:untitled3/features/sound_detection/presentation/pages/emergency_alert_page.dart';
import 'package:untitled3/features/sound_detection/presentation/pages/sound_monitor_page.dart';
import 'package:untitled3/features/video_chat/presentation/widgets/HandTrackingWidget.dart';
import 'package:untitled3/features/home/presentation/pages/home_view.dart';
import 'package:untitled3/features/search/presentation/views/search_view.dart';
import 'package:untitled3/features/video_chat/presentation/pages/VideoChatTest.dart';
import 'package:untitled3/features/video_home/presentation/views/chat_home.dart';
import 'package:untitled3/features/video_home/presentation/views/widgets/help_screen.dart';
import 'package:untitled3/features/account/presentation/pages/account_page.dart';
import 'package:untitled3/main.dart';

import '../../features/alarm/domain/entities/alarm_entity.dart';
import '../../features/alarm/presentation/pages/alarm_page.dart';
import '../../features/alarm/presentation/pages/set_alarm_page.dart';
import '../../features/learning/presentation/pages/course_detail_page.dart';
import '../../features/sound_detection/presentation/pages/sound_alert_page.dart';
import '../../features/magnify/presentation/TextMagnifierSpeakerScreen.dart';
import '../../features/video_home/presentation/views/widgets/homView_body.dart';
import '../transitions/page_transitions.dart';

abstract class AppRoute {
  static String welcomePath = '/';
  //todo solve
  static String chatHomePath = '/chat_home';
  static String kChatPath = '/chat';
  static String kSearchPath = '/SearchView';
  static String homePath = '/main';
  //static String kSearchPath = '/search';

  static String signInPath = '/signin';
  static String signUpPath = '/signup';
  static String forgetPasswordPath = '/forgot_password';
  static String chatTestPath = '/chat_test';
  static String videoChatTestPath = '/video_test';
  static String helpPath = '/help';
  static String accountPath = '/account';
  static String magnifierPath = '/magnifier';
  static String learningHome = '/learningHome';
  static String courseDetail = '/course_detail';
  static String soundDetection = '/soundDetection';
  static String alarmPath = '/alarm';
  static String setAlarmPath = '/set_alarm';
  static String handTracking = '/handTracking';
  static String emergencyAlarm = '/emergencyAlarm';

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();


  static final router = GoRouter(
    observers: [routeObserver],
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(path: homePath,
        pageBuilder: (context, state) {
          return AppTransitions.buildPageWithTransition(
            context,
            state,
            HomeView(),
            transitionType: TransitionType.scale,
          );
        },
      ),
      GoRoute(path: welcomePath, builder: (_, __) => WelcomeScreen()),
      GoRoute(path: chatHomePath, builder: (_, __) => const ChatHome()),
      GoRoute(path: kChatPath, builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ChatView(
          senderId: extra['senderId'],
          receiverId: extra['receiverId'],
        );
      }),
      GoRoute(path: kSearchPath, builder: (_, __) => const SearchView()),
      GoRoute(
        path: signInPath,
        pageBuilder: (context, state) => AppTransitions.buildPageWithTransition(
          context,
          state,
          const SignInScreen(),
          transitionType: TransitionType.slideAndFade,
        ),
      ),
      GoRoute(path: signUpPath,
        pageBuilder: (context, state) => AppTransitions.buildPageWithTransition(
          context,
          state,
          const SignUpScreen(),
          transitionType: TransitionType.slideAndFade,
        ),
      ),
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
      GoRoute(path: accountPath, builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return AccountPage(prevPath: extra['prevPath']);
      }),
      GoRoute(path: learningHome,
          // builder: (_, __) => const LearningHome()
        pageBuilder: (context, state) => AppTransitions.buildPageWithTransition(
          context,
          state,
          const LearningHome(),
          transitionType: TransitionType.slideAndFade,
        ),
      ),
      GoRoute(path: courseDetail,
          pageBuilder: (context, state) {
        final extra = state.extra as Course;
        // return CourseDetailPage(course: extra);
        return AppTransitions.buildPageWithTransition(
          context,
          state,
          CourseDetailPage(course: extra),
          transitionType: TransitionType.scale,
        );
      }),
      GoRoute(
        path: magnifierPath,
        // builder: (_, __) => const TextMagnifierSpeakerScreen(),
        pageBuilder: (context, state) => AppTransitions.buildPageWithTransition(
          context,
          state,
          const TextMagnifierSpeakerScreen(),
          transitionType: TransitionType.slideAndFade,
        ),
      ),
      // GoRoute(
      //   path: soundDetection,
      //   builder: (_, __) => const SoundMonitorPage(),
      // ),
      GoRoute(path: soundDetection,
          // builder: (_, __) =>  SoundAlertPage()
        pageBuilder: (context, state) => AppTransitions.buildPageWithTransition(
          context,
          state,
          SoundAlertPage(),
          transitionType: TransitionType.slideAndFade,
        ),
      ),
      // GoRoute(path: soundDetection, builder: (_, __) =>  const SoundMonitorPage()),
      GoRoute(path: alarmPath,
          // builder: (_, __) => const AlarmPage()
        pageBuilder: (context, state) => AppTransitions.buildPageWithTransition(
          context,
          state,
          const AlarmPage(),
          transitionType: TransitionType.slideAndFade,
        ),
      ),
      GoRoute(path: emergencyAlarm, builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return EmergencyAlertPage(
          detectedSound: extra['detectedSound'],
          confidenceLevel: extra['confidenceLevel'],
        );
  }),

      GoRoute(path: handTracking, builder: (_, __) => HandTrackingWidget()),
      GoRoute(
        path: AppRoute.setAlarmPath,
        builder: (context, state) {
          final alarm = state.extra as Alarm?;
          print('Alarm date before navigating: ${alarm?.time.toString()}');
          return SetAlarmPage(alarm: alarm);
        },
      ),
    ],
  );
}











