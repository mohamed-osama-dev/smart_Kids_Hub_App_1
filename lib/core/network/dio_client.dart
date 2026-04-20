import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'secure_storage_service.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  String? _sessionToken;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _sessionToken ?? await SecureStorageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final hasRetried = error.requestOptions.extra['_retried'] == true;
          if (statusCode != 401 || _sessionToken != null || hasRetried) {
            handler.next(error);
            return;
          }

          final refreshToken = await SecureStorageService.getRefreshToken();
          if (refreshToken == null || refreshToken.isEmpty) {
            handler.next(error);
            return;
          }

          try {
            final refreshResponse = await Dio().post(
              '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
              options: Options(
                headers: {'Authorization': 'Bearer $refreshToken'},
              ),
            );
            final wrapper = refreshResponse.data;
            if (wrapper is! Map<String, dynamic>) {
              handler.next(error);
              return;
            }
            final data = wrapper['data'];
            if (data is! Map<String, dynamic>) {
              handler.next(error);
              return;
            }
            final newAccessToken = data['accessToken']?.toString();
            final newRefreshToken = data['refreshToken']?.toString();
            if (newAccessToken == null || newRefreshToken == null) {
              handler.next(error);
              return;
            }

            await SecureStorageService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            requestOptions.extra['_retried'] = true;

            final retryResponse = await dio.fetch(requestOptions);
            handler.resolve(retryResponse);
            return;
          } on DioException {
            handler.next(error);
            return;
          }
        },
      ),
    );
  }

  void setSessionToken(String? token) {
    _sessionToken = token;
  }

  void clearSessionToken() {
    _sessionToken = null;
  }
}
