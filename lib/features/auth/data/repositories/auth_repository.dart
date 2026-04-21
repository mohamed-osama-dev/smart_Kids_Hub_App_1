import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/child.dart';

class AuthRepository {
  final _client = DioClient();

  Future<String> registerParent({
    required String fullName,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.registerParent,
      data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    final data = _parseResponse(response.data);
    final sessionToken = data['sessionToken']?.toString();
    if (sessionToken == null || sessionToken.isEmpty) {
      throw ApiException('Session token not found');
    }
    return sessionToken;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String sessionToken,
    required String verifyCode,
  }) async {
    _client.setSessionToken(sessionToken);
    try {
      final response = await _client.dio.post(
        ApiConstants.verifyOtp,
        data: {'verifyCode': verifyCode},
      );
      return _parseResponse(response.data);
    } finally {
      _client.clearSessionToken();
    }
  }

  Future<int> addChild({
    required String name,
    required DateTime birthDate,
    required Gender gender,
    required double length,
    required double weight,
  }) async {
    final genderValue = gender == Gender.male ? 0 : 1;
    try {
      final response = await _client.dio.post(
        ApiConstants.addChild,
        data: {
          'name': name,
          'BirthDate': birthDate.toIso8601String().split('T').first,
          'gender': genderValue,
          'length': length,
          'weight': weight,
        },
      );

      final data = _parseResponse(response.data);
      final childIdRaw = data['childId'];
      final childId = childIdRaw is int
          ? childIdRaw
          : int.tryParse(childIdRaw?.toString() ?? '');
      if (childId == null) {
        throw ApiException('Child id not found');
      }
      return childId;
    } on DioException catch (e) {
      print('ADD CHILD ERROR: ${e.response?.data}');
      throw ApiException(_extractDioMessage(e));
    }
  }

  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.login,
      data: {'phoneNumber': phoneNumber, 'password': password},
    );
    return _parseResponse(response.data);
  }

  Future<void> logout() async {
    final response = await _client.dio.post(ApiConstants.logout);
    _parseResponse(response.data);
  }

  Future<String> forgotPassword({required String phoneNumber}) async {
    final response = await _client.dio.post(
      ApiConstants.forgotPassword,
      data: {'phoneNumber': phoneNumber},
    );
    final data = _parseResponse(response.data);
    final sessionToken = data['sessionToken']?.toString();
    if (sessionToken == null || sessionToken.isEmpty) {
      throw ApiException('Session token not found');
    }
    return sessionToken;
  }

  Future<void> resendCode({required String sessionToken}) async {
    _client.setSessionToken(sessionToken);
    try {
      final response = await _client.dio.post(ApiConstants.resendCode);
      _parseResponse(response.data);
    } finally {
      _client.clearSessionToken();
    }
  }

  Future<void> setNewPassword({
    required String sessionToken,
    required String password,
    required String confirmPassword,
  }) async {
    _client.setSessionToken(sessionToken);
    try {
      final response = await _client.dio.post(
        ApiConstants.setNewPassword,
        data: {'password': password, 'confirmPassword': confirmPassword},
      );
      _parseResponse(response.data);
    } finally {
      _client.clearSessionToken();
    }
  }

  Map<String, dynamic> _parseResponse(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw ApiException('Invalid response format');
    }

    final success = raw['success'] == true;
    final message = raw['message']?.toString();
    if (!success) {
      final errors = raw['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw ApiException(errors.first.toString());
      }
      throw ApiException(message ?? 'Request failed');
    }

    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data == null) {
      return <String, dynamic>{};
    }
    throw ApiException('Invalid data payload');
  }

  String _extractDioMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      }
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return error.message ?? 'Request failed';
  }
}
