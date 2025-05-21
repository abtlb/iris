// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AgoraService.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _AgoraService implements AgoraService {
  _AgoraService(
      this._dio, {
        this.baseUrl,
      }) {
    baseUrl ??= 'http://gradprojapi.somee.com/api';  // fallback للbaseUrl
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<TokenResponse> getToken(String channelName) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{'channelName': channelName};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;

    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<TokenResponse>(
        Options(
          method: 'GET',
          headers: _headers,
          extra: _extra,
        ).compose(
          _dio.options,
          '/Agora/token',
          queryParameters: queryParameters,
          data: _data,
        ).copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl),
      ),
    );
    final value = TokenResponse.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
