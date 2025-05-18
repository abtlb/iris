import 'package:untitled3/features/account/data/datasources/updateAccountService.dart';
import 'package:untitled3/features/account/data/models/update_account_model.dart';
import 'package:untitled3/features/account/domain/entities/update_account_entity.dart';
import 'package:untitled3/features/account/domain/repositories/update_account_repository.dart';
import 'package:untitled3/features/auth/domain/entities/UserEntity.dart';

class UpdateAccountRepositoryImpl extends UpdateAccountRepository {
  final UpdateAccountService updateAccountService;

  UpdateAccountRepositoryImpl({required this.updateAccountService});

  @override
  Future<UserEntity> updateAccount(UpdateAccountEntity updateAccountEntity) async {
    try {
      final response = await updateAccountService.updateAccount(
        updateAccountEntity.username,
        UpdateAccountModel.fromEntity(updateAccountEntity),
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to update account: $e");
    }
  }
}
