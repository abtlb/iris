// home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FlutterSecureStorage _secureStorage;

  HomeCubit({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        super(HomeInitial());

  static const String _firstNameKey = 'firstName';

  Future<void> loadFirstName() async {
    try {
      emit(HomeLoading());

      final firstName = await _secureStorage.read(key: _firstNameKey);

      if (firstName != null && firstName.isNotEmpty) {
        emit(HomeLoaded(firstName: firstName));
      } else {
        emit(
            const HomeError(message: 'First name not found in secure storage'));
      }
    } catch (e) {
      emit(HomeError(message: 'Failed to load first name: ${e.toString()}'));
    }
  }
  }