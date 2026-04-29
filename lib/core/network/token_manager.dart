import 'dart:async';

import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'secure_storage_service.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;

  late final Dio _refreshDio;
  Completer<bool>? _refreshCompleter;

  TokenManager._internal() {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  bool get isRefreshing =>
      _refreshCompleter != null && !_refreshCompleter!.isCompleted;

  Future<String?> getValidAccessToken() => SecureStorageService.getAccessToken();

  Future<void> clearSession() async {
    await SecureStorageService.clearAll();

    // If callers are waiting on a refresh, complete once with false.
    final completer = _refreshCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
    _refreshCompleter = null;
  }

  Future<bool> refreshAccessToken() async {
    final activeRefresh = _refreshCompleter;
    if (activeRefresh != null) {
      // A refresh is already running; all callers await the same result.
      return activeRefresh.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await SecureStorageService.clearAll();
        if (!completer.isCompleted) completer.complete(false);
        return false;
      }

      final response = await _refreshDio.post(
        ApiConstants.refreshToken,
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        await SecureStorageService.clearAll();
        if (!completer.isCompleted) completer.complete(false);
        return false;
      }

      if (raw.containsKey('success') && raw['success'] != true) {
        await SecureStorageService.clearAll();
        if (!completer.isCompleted) completer.complete(false);
        return false;
      }

      final tokenContainer = raw['data'] is Map<String, dynamic>
          ? raw['data'] as Map<String, dynamic>
          : raw;

      final newAccessToken = tokenContainer['accessToken']?.toString();
      final newRefreshToken = tokenContainer['refreshToken']?.toString();

      if (newAccessToken == null ||
          newAccessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        await SecureStorageService.clearAll();
        if (!completer.isCompleted) completer.complete(false);
        return false;
      }

      await SecureStorageService.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      if (!completer.isCompleted) completer.complete(true);
      return true;
    } on DioException {
      await SecureStorageService.clearAll();
      if (!completer.isCompleted) completer.complete(false);
      return false;
    } catch (_) {
      await SecureStorageService.clearAll();
      if (!completer.isCompleted) completer.complete(false);
      return false;
    } finally {
      if (identical(_refreshCompleter, completer)) {
        _refreshCompleter = null;
      }
    }
  }
}

