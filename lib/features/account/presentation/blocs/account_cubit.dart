import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled3/features/account/domain/entities/update_account_entity.dart';
import 'package:untitled3/features/account/domain/usecases/update_account.dart';
import 'package:untitled3/features/auth/domain/usecases/get_user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../domain/usecases/update_avatar.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final UploadAvatarUsecase updateProfileImageUseCase;
  final GetUserUseCase getUserUseCase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final UpdateAccountUseCase updateAccountUseCase;
  final FlutterSecureStorage storage = const FlutterSecureStorage();


  AccountCubit({
    required this.updateProfileImageUseCase,
    required this.getUserUseCase,
    required this.updateAccountUseCase,
    required this.getCurrentUserUsecase,
  }) : super(const AccountState.initial(null, null, null, null, null, null, null));

  Future<void> updateUserInfo(UpdateAccountEntity updateEntity) async {
    emit(state.copyWith(status: AccountStatus.loading));

    try {
      final updatedUser = await updateAccountUseCase.call(updateEntity);
      await storage.write(key: 'firstName', value: updateEntity.firstName);
      emit(state.copyWith(
        firstName: updatedUser.firstName,
        lastName: updatedUser.lastName,
        email: updatedUser.email,
        dob: updatedUser.dateOfBirth,
        imageUrl: updatedUser.imageUrl,
        status: AccountStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: e.toString()));
    }
  }

  Future<void> fetchCurrentUser() async {
    emit(state.copyWith(status: AccountStatus.loading));
    var user = await getCurrentUserUsecase.call();
    emit(state.copyWith(
      username: user.username,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      dob: user.dateOfBirth,
      status: AccountStatus.success,
      imageUrl: user.imageUrl,
    ));
  }

  Future<void> updateProfileImage() async {
    emit(state.copyWith(status: AccountStatus.loading));

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        emit(state.copyWith(status: AccountStatus.initial));
        return;
      }

      await updateProfileImageUseCase.call(state.username!, File(picked.path));
      final user = await getUserUseCase(params: state.username!);
      emit(state.copyWith(imageUrl: user.data?.imageUrl, status: AccountStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: e.toString()));
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: AccountStatus.initial, error: null));
  }
}
