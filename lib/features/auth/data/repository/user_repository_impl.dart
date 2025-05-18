import 'dart:io';

import 'package:dio/dio.dart';
import 'package:untitled3/core/resources/data_state.dart';
import 'package:untitled3/core/storage/storage.dart';
import 'package:untitled3/features/auth/data/data_sources/remote/ApiService.dart';
import 'package:untitled3/features/auth/data/models/user.dart';
import 'package:untitled3/features/auth/domain/entities/UserEntity.dart';
import 'package:untitled3/features/auth/domain/repository/UserRepository.dart';

class UserRepositoryImpl implements UserRepository {

  final ApiService apiService;

  UserRepositoryImpl(this.apiService);

  @override
  Future<DataState<List<UserModel>>> getUsers() async {
    try
    {
      final httpResponse = await apiService.getUsers();

      if(httpResponse.response.statusCode == HttpStatus.ok){
        return DataSuccess(httpResponse.data);
      }
      else
      {
        return DataFailed(DioException(
          error: httpResponse.response.statusMessage,
          response: httpResponse.response,
          type: DioExceptionType.badResponse,
          requestOptions: httpResponse.response.requestOptions

        ));
      }
    }
    on DioException catch(e){
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserModel>> getUser(String username) async {
    try
    {
      final httpResponse = await apiService.getUser(username);

      if(httpResponse.response.statusCode == HttpStatus.ok){
        return DataSuccess(httpResponse.data);
      }
      else
      {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions

        ));
      }
    }
    on DioException catch(e){
      return DataFailed(e);
    }
  }

  @override
  Future<void> uploadPfp(File img, String username) async{
    await apiService.uploadAvatar(username, img);
  }

  @override
  Future<DataState<UserEntity>> getCurrentUser() async {
    try
    {
      final httpResponse = await apiService.getCurrentUser();

      if(httpResponse.response.statusCode == HttpStatus.ok){
        return DataSuccess(httpResponse.data);
      }
      else
      {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions

        ));
      }
    }
    on DioException catch(e){
      return DataFailed(e);
    }
  }
}