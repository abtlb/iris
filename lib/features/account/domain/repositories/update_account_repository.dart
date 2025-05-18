import 'package:untitled3/features/account/domain/entities/update_account_entity.dart';
import 'package:untitled3/features/auth/domain/entities/UserEntity.dart';

abstract class UpdateAccountRepository {
  Future<UserEntity> updateAccount(UpdateAccountEntity updateAccountEntity);
}