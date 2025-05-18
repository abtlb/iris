import 'package:untitled3/features/account/domain/entities/update_account_entity.dart';

class UpdateAccountModel extends UpdateAccountEntity {
  UpdateAccountModel({
    super.firstName,
    super.lastName,
    super.dateOfBirth,
    super.email,
    required super.username,
  });

  Map<String, dynamic> toJson() {
    final dob = dateOfBirth;
    if (dob == null) {
      // if your API allows null dates, you can emit null here.
      // Otherwise throw or handle appropriately.
      return {
        'firstName': firstName,
        'lastName':  lastName,
        'email':     email,
        'dateOfBirth': null,
      };
    }

    // Format as "YYYY-MM-DD"
    final dobString = '${dob.year.toString().padLeft(4, '0')}-'
        '${dob.month.toString().padLeft(2, '0')}-'
        '${dob.day.toString().padLeft(2, '0')}';

    return {
      'firstName':   firstName,
      'lastName':    lastName,
      'email':       email,
      'dateOfBirth': dobString,
    };
  }


  static UpdateAccountModel fromEntity(UpdateAccountEntity entity) {
    return UpdateAccountModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      dateOfBirth: entity.dateOfBirth,
      email: entity.email,
      username: entity.username,
    );
}

}