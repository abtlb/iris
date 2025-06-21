import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';
import 'package:untitled3/features/auth/data/models/user.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/env.dart';
import '../models/update_account_model.dart';

part 'updateAccountService.g.dart';

@RestApi(baseUrl: apiBaseURL)
abstract class UpdateAccountService {
  factory UpdateAccountService(Dio dio) = _UpdateAccountService;

  @PUT('/User/UpdateUser/{username}')
  Future<HttpResponse<UserModel>> updateAccount(@Path("username") String username, @Body() UpdateAccountModel data);
}