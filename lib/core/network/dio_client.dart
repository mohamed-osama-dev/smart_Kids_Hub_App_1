import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../utils/app_routes.dart';
import 'api_constants.dart';
import 'token_manager.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final StreamController<void> _logoutController =
      StreamController<void>.broadcast();

  static Stream<void> get logoutEvents => _logoutController.stream;

  late final Dio dio;
  String? _sessionToken;
  final TokenManager _tokenManager = TokenManager();
  Future<void>? _sessionExpiryTask;

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
          var token = _sessionToken;
          if (token == null || token.isEmpty) {
            token = await _tokenManager.getValidAccessToken();
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode != 401) {
            handler.next(error);
            return;
          }

          if (_sessionToken != null) {
            // OTP/session-token requests should not trigger refresh flow.
            handler.next(error);
            return;
          }

          final requestOptions = error.requestOptions;
          final hasRetried = requestOptions.extra['_retried'] == true;
          if (hasRetried) {
            handler.next(error);
            return;
          }

          final refreshed = await _tokenManager.refreshAccessToken();
          if (!refreshed) {
            await _handleSessionExpired();
            handler.next(error);
            return;
          }

          final newToken = await _tokenManager.getValidAccessToken();
          if (newToken == null || newToken.isEmpty) {
            await _handleSessionExpired();
            handler.next(error);
            return;
          }

          try {
            final retryHeaders = Map<String, dynamic>.from(requestOptions.headers)
              ..['Authorization'] = 'Bearer $newToken';
            final retryExtra = Map<String, dynamic>.from(requestOptions.extra)
              ..['_retried'] = true;

            final retriedOptions = requestOptions.copyWith(
              headers: retryHeaders,
              extra: retryExtra,
            );

            final retryResponse = await dio.fetch(retriedOptions);
            handler.resolve(retryResponse);
          } catch (_) {
            handler.next(error);
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

  Future<void> _handleSessionExpired() {
    final activeTask = _sessionExpiryTask;
    if (activeTask != null) return activeTask;

    final task = _performSessionExpiryActions();
    _sessionExpiryTask = task;
    return task.whenComplete(() {
      _sessionExpiryTask = null;
    });
  }

  Future<void> _performSessionExpiryActions() async {
    await _tokenManager.clearSession();
    _logoutController.add(null);

    const message = 'انتهت جلستك، يرجى تسجيل الدخول مجدداً';
    final navigator = navigatorKey.currentState;
    final messenger = scaffoldMessengerKey.currentState;

    if (navigator != null) {
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }

    if (messenger != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(message)),
        );
    }
  }
}
