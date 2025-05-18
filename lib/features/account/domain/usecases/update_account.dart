// lib/features/account/domain/usecases/update_account.dart

import 'package:untitled3/features/account/domain/entities/update_account_entity.dart';
import 'package:untitled3/features/auth/domain/entities/UserEntity.dart';
import 'package:untitled3/features/account/domain/repositories/update_account_repository.dart';

class UpdateAccountUseCase {
  final UpdateAccountRepository _repository;

  UpdateAccountUseCase(this._repository);

  Future<UserEntity> call(UpdateAccountEntity params) {
    return _repository.updateAccount(params);
  }
}
