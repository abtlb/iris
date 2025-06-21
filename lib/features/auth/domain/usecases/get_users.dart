import 'package:untitled3/core/resources/data_state.dart';
import 'package:untitled3/core/usecases/usecase.dart';
import 'package:untitled3/features/auth/domain/entities/UserEntity.dart';
import 'package:untitled3/features/auth/domain/repository/UserRepository.dart';

class GetUsersUseCase implements UseCase<DataState<List<UserEntity>>,void> {

final UserRepository userRepository;

GetUsersUseCase(this.userRepository);

  @override
  Future<DataState<List<UserEntity>>> call({params}) {
    return userRepository.getUsers();
  }
}