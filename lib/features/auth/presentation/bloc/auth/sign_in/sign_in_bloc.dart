import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled3/features/auth/domain/usecases/get_current_user.dart';
import 'package:untitled3/features/auth/domain/usecases/sign_in.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_events.dart';
import 'package:untitled3/features/auth/presentation/bloc/auth/sign_in/sign_in_states.dart';

import '../../../../../video_chat/services/ speech_to_text_service.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInUseCase signInUseCase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  SignInBloc({required this.signInUseCase, required this.getCurrentUserUsecase}) : super(SignInInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(SignInLoading());

      try {
        final tokenEntity = await signInUseCase.call(event.username, event.password);
        final user = await getCurrentUserUsecase.call();

        // Save the username in secure storage
        await storage.write(key: 'username', value: event.username);
        await storage.write(key: 'firstName', value: user.firstName);

        emit(SignInSuccess(tokenEntity.token));
      } catch (e) {
        emit(SignInFailure(e.toString()));
      }
    });
  }
}


