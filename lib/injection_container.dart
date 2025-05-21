import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/core/storage/storage.dart';
import 'package:untitled3/core/services/local_notification_ds.dart';
import 'package:untitled3/features/account/data/datasources/updateAccountService.dart';
import 'package:untitled3/features/account/domain/repositories/update_account_repository.dart';
import 'package:untitled3/features/account/domain/usecases/update_account.dart';
import 'package:untitled3/features/account/domain/usecases/update_avatar.dart';
import 'package:untitled3/features/alarm/data/%20services/alarm_callback_service.dart';
import 'package:untitled3/features/alarm/data/%20services/alarm_notification_ds.dart';
import 'package:untitled3/features/alarm/data/%20services/flash_service.dart';
import 'package:untitled3/features/alarm/data/%20services/vibration_service.dart';
import 'package:untitled3/features/alarm/data/repositories/alarm_repository_impl.dart';
import 'package:untitled3/features/alarm/domain/repositories/alarm_repository.dart';
import 'package:untitled3/features/auth/data/data_sources/remote/ApiService.dart';
import 'package:untitled3/features/auth/data/repository/auth_repository_impl.dart';
import 'package:untitled3/features/auth/data/repository/user_repository_impl.dart';
import 'package:untitled3/features/auth/domain/repository/UserRepository.dart';
import 'package:untitled3/features/auth/domain/repository/auth_repository.dart';
import 'package:untitled3/features/auth/domain/usecases/get_current_user.dart';
import 'package:untitled3/features/auth/domain/usecases/get_user.dart';
import 'package:untitled3/features/auth/domain/usecases/get_users.dart';
import 'package:untitled3/features/auth/domain/usecases/sign_in.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_bloc.dart';
import 'package:untitled3/features/auth/presentation/bloc/remote_user/remote_user_bloc.dart';
import 'package:untitled3/features/chat/data/data_sources/chat_source.dart';
import 'package:untitled3/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:untitled3/features/chat/domain/repositories/chat_repository.dart';
import 'package:untitled3/features/chat/domain/usecases/chat_usecase.dart';
import 'package:untitled3/features/sound_detection/data/data_sources/sound_local_datasource.dart';
import 'package:untitled3/features/sound_detection/data/data_sources/sound_local_datasource_impl.dart';
import 'package:untitled3/features/sound_detection/data/models/sound_classifier_model.dart';
import 'package:untitled3/features/sound_detection/data/repositories/sound_repository_impl.dart';
import 'package:untitled3/features/sound_detection/domain/repositories/sound_repository.dart';
import 'package:untitled3/features/sound_detection/domain/usecases/start_sound_classification_use_case.dart';
import 'package:untitled3/features/sound_detection/presentation/bloc/sound_monitor_cubit.dart';
import 'package:untitled3/features/video_chat/data/others/asl_detector.dart';
import 'package:untitled3/features/video_chat/data/others/frame_observer.dart';
import 'package:untitled3/features/video_chat/domain/usecases/getPredictionStream.dart';
import 'package:untitled3/features/video_home/data/data_source/ConversationService.dart';
import 'package:untitled3/features/video_home/domain/repository/ChatHomeRepository.dart';
import 'package:untitled3/features/video_home/domain/usecase/GetConversationsUsecase.dart';
import 'package:untitled3/features/video_home/domain/usecase/GetSenderIdUsecase.dart';
import 'package:untitled3/features/video_home/presentation/bloc/chat_home_bloc.dart';
import 'package:untitled3/features/video_chat/data/data_sources/AgoraService.dart';
import 'package:untitled3/features/video_chat/data/repository/AgoraVideoChatRepository.dart';
import 'package:untitled3/features/video_chat/domain/repository/VideoChatRepository.dart';
import 'package:untitled3/features/video_chat/domain/usecases/GetLocalUserStreamUsecase.dart';
import 'package:untitled3/features/video_chat/domain/usecases/GetRemoteUserStreamUsecase.dart';
import 'package:untitled3/features/video_chat/domain/usecases/connectToVideoChat.dart';
import 'package:untitled3/features/video_chat/domain/usecases/disconnectFromVideoChat.dart';
import 'package:untitled3/features/video_chat/presentation/bloc/video_chat_bloc.dart';

import 'features/account/data/repositories/update_account_repository_impl.dart';
import 'features/account/presentation/blocs/account_cubit.dart';
import 'features/alarm/data/datasources/local_alarm_data_source.dart';
import 'features/alarm/presentation/bloc/alarm_form/alarm_form_cubit.dart';
import 'features/alarm/presentation/bloc/alarm_list/alarm_list_cubit.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/bloc/auth/sign_up/sign_up_bloc.dart';
import 'features/chat/presentation/blocs/chat_bloc.dart';
import 'features/sound_detection/domain/usecases/monitor_sound.dart';
import 'features/sound_detection/domain/usecases/stop_sound_classification_use_case.dart';
import 'features/video_chat/data/others/hands_service.dart';
import 'features/video_home/data/repository/ChatHomeRepositoryImpl.dart';

final sl = GetIt.instance;

Future<void> initializeDependancies() async {
  sl.registerSingleton<SecureStorage>(
      SecureStorage()
  );

  sl.registerSingleton<Dio>(createDioWithToken(sl()));

  sl.registerSingleton<FlutterLocalNotificationsPlugin>(FlutterLocalNotificationsPlugin());
  sl.registerSingleton<LocalNotificationDataSource>(LocalNotificationDataSource(sl()));

  await initializeAuth();

  sl.registerSingleton<ChatService>(ChatService(secureStorage: sl()));

  sl.registerSingleton<ChatRepository>(ChatRepositoryImpl(sl()));

  sl.registerSingleton<ChatUseCase>(ChatUseCase(sl()));

  sl.registerFactory<ChatBloc>(
          () => ChatBloc(chatUseCase: sl())
  );

  sl.registerSingleton<ConversationService>(ConversationService(sl()));
  sl.registerSingleton<ChatHomeRepository>(ChatHomeRepositoryImpl(service: sl(), secureStorage: sl()));
  sl.registerSingleton<GetConversationUsecase>(GetConversationUsecase(chatHomeRepository: sl()));
  sl.registerSingleton<GetSenderIdUseCase>(GetSenderIdUseCase(chatHomeRepository: sl()));
  sl.registerFactory<ChatHomeBloc>(
      () => ChatHomeBloc(getConversationUsecase: sl(), getSenderIdUseCase: sl())
  );


  //for the sound detection feature
  sl.registerSingleton<SoundLocalDataSource>(SoundLocalDataSourceImpl());
  sl.registerSingleton<SoundClassifier>(SoundClassifier());
  sl.registerSingleton<SoundRepository>(SoundRepositoryImpl(sl(), sl()));
  // sl.registerSingleton<MonitorSoundUsecase>(FakeMonitorSound());
  sl.registerSingleton<MonitorSoundUsecase>(RealMonitorSound(repository: sl()));
  sl.registerSingleton<StartSoundClassificationUseCase>(StartSoundClassificationUseCase(sl()));
  sl.registerSingleton<StopSoundClassificationUseCase>(StopSoundClassificationUseCase(sl()));
  sl.registerFactory<SoundMonitorCubit>(() => SoundMonitorCubit(startClassification: sl(), stopClassification: sl(), monitorNoise: sl()));

  //for the alarm feature
  sl.registerSingleton<LocalAlarmDataSource>(LocalAlarmDataSource());
  sl.registerSingleton<AlarmCallbackService>(AlarmCallbackService());
  final alarmNotificationService = AlarmNotificationService(sl());
  alarmNotificationService.initialize();
  sl.registerSingleton<AlarmNotificationService>(alarmNotificationService);
  sl.registerSingleton<AlarmRepository>(
    AlarmRepositoryImpl(
      notifications: sl(),
      localAlarmDataSource: sl(),
      alarmCallbackService: sl(),
    ),
  );
  sl.registerFactory(() => AlarmListCubit(repository: sl()));
  sl.registerFactory(() => AlarmFormCubit());

  await initializeVideoChatDependencies();

  sl.registerSingleton<UpdateAccountService>(UpdateAccountService(sl()));
  sl.registerSingleton<UpdateAccountRepository>(UpdateAccountRepositoryImpl(updateAccountService: sl()));
  sl.registerSingleton<UploadAvatarUsecase>(UploadAvatarUsecase(apiService: sl()));
  sl.registerSingleton<UpdateAccountUseCase>(UpdateAccountUseCase(sl()));
  sl.registerSingleton<GetCurrentUserUsecase>(GetCurrentUserUsecase(userRepository: sl()));
  sl.registerFactory<AccountCubit>(() => AccountCubit(updateProfileImageUseCase: sl(), getUserUseCase: sl(), updateAccountUseCase: sl(), getCurrentUserUsecase: sl()));
}

Future<void> initializeAuth() async {
  sl.registerSingleton<ApiService>(ApiService(sl()));

  sl.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(sl(), sl())
  );

  sl.registerSingleton<UserRepository>(
      UserRepositoryImpl(sl())
  );

  sl.registerSingleton<GetUserUseCase>(
    GetUserUseCase(sl())
  );

  sl.registerSingleton<GetUsersUseCase>(
      GetUsersUseCase(sl())
  );

  sl.registerFactory<RemoteUsersBloc>(
          () => RemoteUsersBloc(sl())
  );

  sl.registerSingleton<SignInUseCase>(
      SignInUseCase(sl())
  );

  sl.registerFactory<SignInBloc>(
          () => SignInBloc(sl())
  );

  sl.registerSingleton<SignUpUseCase>(
      SignUpUseCase(authRepository: sl())
  );

  sl.registerFactory<SignUpBloc>(
          () => SignUpBloc(sl())
  );
}

Future<void> initializeVideoChatDependencies() async {
  sl.registerSingleton<AgoraService>(
    AgoraService(sl())
  );

  sl.registerSingleton<ASLDetector>(await ASLDetector.initialize());
  sl.registerSingleton<Hands>(await Hands.initialize());
  sl.registerSingleton<FrameObserver>(FrameObserver(aslDetector: sl(), hands: sl()));
  sl.registerSingleton<VideoChatRepository>(
        AgoraVideoChatRepository(agoraService: sl(), frameObserver: sl()),
  );


  // Register the use cases that depend on the repository.
  sl.registerSingleton<ConnectToVideoChatUsecase>(
        ConnectToVideoChatUsecase(repository: sl()),
  );

  sl.registerSingleton<DisconnectFromVideoChatUsecase>(
    DisconnectFromVideoChatUsecase(videoChatRepository: sl()),
  );

  sl.registerSingleton<GetLocalUserStreamUsecase>(
        GetLocalUserStreamUsecase(repository: sl<VideoChatRepository>()),
  );

  sl.registerSingleton<GetRemoteUserStreamUsecase>(
    GetRemoteUserStreamUsecase(repository: sl()),
  );

  sl.registerSingleton<GetPredictionStreamUsecase>(GetPredictionStreamUsecase(videoChatRepository: sl()));

  // Register the BLoC. Using registerFactory here to create a new instance each time.
  sl.registerFactory<VideoChatBloc>(() => VideoChatBloc(
    connectUsecase: sl(),
    disconnectUsecase: sl(),
    getLocalUserStreamUsecase: sl(),
    getRemoteUserStreamUsecase: sl(),
  ));

}

Dio createDioWithToken(SecureStorage secureStorage) {
  final dio = Dio();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Retrieve the token from secure storage.
        final token = await secureStorage.getToken();
        if (token != null && token.isNotEmpty) {
          // Add the token to the Authorization header.
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ),
  );

  return dio;
}