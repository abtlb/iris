import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/features/video_chat/data/models/token_response.dart';

import '../../../../core/env.dart';

part 'AgoraService.g.dart';

@RestApi(baseUrl: apiBaseURL)  // apiBaseURL معرف في constants.dart
abstract class AgoraService {
  factory AgoraService(Dio dio) = _AgoraService;

  @GET('/Agora/token')
  Future<TokenResponse> getToken(@Query('channelName') String channelName);
}
