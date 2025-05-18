import 'package:untitled3/features/auth/domain/entities/UserEntity.dart';

import '../repository/UserRepository.dart';

class GetCurrentUserUsecase {
  final UserRepository userRepository;

  GetCurrentUserUsecase({required this.userRepository});

  Future<UserEntity> call() async {
    var currUserData = await userRepository.getCurrentUser();
    if(currUserData.data == null)
    {
      throw Exception("Couldn't get current user");
    }
    return currUserData.data!;
  }
}