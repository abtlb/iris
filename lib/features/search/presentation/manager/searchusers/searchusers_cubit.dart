import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:untitled3/features/auth/domain/entities/UserEntity.dart';
import 'package:untitled3/features/auth/domain/usecases/get_users.dart';
import 'package:untitled3/features/video_home/domain/entity/ConversationEntity.dart';
import 'package:untitled3/features/video_home/domain/usecase/GetConversationsUsecase.dart';
import 'package:untitled3/features/video_home/domain/usecase/GetSenderIdUsecase.dart';

part 'searchusers_state.dart';

class SearchusersCubit extends Cubit<SearchusersState> {
  SearchusersCubit({required this.getUsersUseCase, required this.getSenderIdUseCase})
      : super(SearchusersInitial());

  final GetUsersUseCase getUsersUseCase;
  final GetSenderIdUseCase getSenderIdUseCase;

  void filterNames({required String name}) async {
    var users = await getUsersUseCase.call();
    var senderId = await getSenderIdUseCase();
    if (name.isEmpty) {
      emit(SearchusersInitial());
    } else {
      emit(SearchusersLoading());

      final filteredList = users.data!
          .where(
            (filterName) => filterName.username
                .toString()
                .toLowerCase()
                .contains(name.toLowerCase()) && senderId != filterName.username,
          )
          .toList();
      if (filteredList.isNotEmpty) {
        emit(SearchusersFilter(filterNames: filteredList, senderId));
      } else {
        emit(SearchusersFailure());
      }
    }
  }
}
