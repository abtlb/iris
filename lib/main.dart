import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/features/sound_detection/presentation/bloc/sound_monitor_cubit.dart';
import 'package:untitled3/features/video_home/presentation/bloc/chat_home_bloc.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/video_chat_bloc.dart';
import 'package:untitled3/injection_container.dart';
import 'features/auth/presentation/bloc/auth/sign_in/sign_in_bloc.dart';
import 'features/auth/presentation/bloc/auth/sign_up/sign_up_bloc.dart';
import 'features/chat/presentation/blocs/chat_bloc.dart';
import 'providers/language_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled3/core/util/app_route.dart';



Future<void> main() async {
  await initializeDependancies();
  final GetIt locator = GetIt.instance;
  runApp(
      MultiProvider(
        providers: [
          BlocProvider<SignInBloc>(
            create: (_) => locator<SignInBloc>(),
          ),
          BlocProvider<SignUpBloc>(
            create: (_) => locator<SignUpBloc>()
          ),
          BlocProvider<ChatBloc>(
            create: (_) => locator<ChatBloc>()
          ),
          BlocProvider<ChatHomeBloc>(
              create: (_) => locator<ChatHomeBloc>()
          ),
          BlocProvider<VideoChatBloc>(
              create: (_) => locator<VideoChatBloc>()
          ),
          // Add other BlocProviders here if needed.
          BlocProvider<SoundMonitorCubit>(
            create: (_) => locator<SoundMonitorCubit>()
          ),
          ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider(),
          ),
          // Add other ChangeNotifierProviders if needed.
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SignChat',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: AppRoute.router,
    );
  }
}