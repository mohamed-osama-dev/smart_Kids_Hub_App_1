import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/child.dart';

class AuthCubit extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool isLoading = false;
  String? errorMessage;
  String? sessionToken;

  Future<bool> registerParent({
    required String fullName,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final normalizedPhone = _normalizeEgyptPhoneNumber(phoneNumber);
      if (normalizedPhone == null) {
        throw ApiException('رقم الهاتف غير صحيح');
      }
      sessionToken = await _repo.registerParent(
        fullName: fullName,
        phoneNumber: normalizedPhone,
        password: password,
        confirmPassword: confirmPassword,
      );
      return true;
    } catch (e) {
      errorMessage = _extractMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({required String verifyCode}) async {
    if (sessionToken == null || sessionToken!.isEmpty) {
      errorMessage = 'Session token is missing';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final data = await _repo.verifyOtp(
        sessionToken: sessionToken!,
        verifyCode: verifyCode,
      );
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      if (accessToken == null || refreshToken == null) {
        throw ApiException('Invalid token response');
      }

      await SecureStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      sessionToken = null;
      return true;
    } catch (e) {
      errorMessage = _extractMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addChildren(List<Child> children) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      for (final child in children) {
        if (child.weight == null || child.height == null) {
          throw ApiException('بيانات الطفل غير مكتملة');
        }
        final ageInYears = _calculateAgeInYears(child.birthDate);
        await _repo.addChild(
          name: child.name,
          age: ageInYears,
          gender: child.gender,
          length: child.height!,
          weight: child.weight!,
        );
      }
      return true;
    } catch (e) {
      errorMessage = _extractMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final normalizedPhone = _normalizeEgyptPhoneNumber(phoneNumber);
      if (normalizedPhone == null) {
        throw ApiException('رقم الهاتف غير صحيح');
      }
      final data = await _repo.login(
        phoneNumber: normalizedPhone,
        password: password,
      );
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      if (accessToken == null || refreshToken == null) {
        throw ApiException('Invalid token response');
      }

      await SecureStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return true;
    } catch (e) {
      errorMessage = _extractMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repo.logout();
    } catch (e) {
      errorMessage = _extractMessage(e);
    } finally {
      await SecureStorageService.clearTokens();
      sessionToken = null;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendCode() async {
    if (sessionToken == null || sessionToken!.isEmpty) {
      errorMessage = 'Session token is missing';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repo.resendCode(sessionToken: sessionToken!);
      return true;
    } catch (e) {
      errorMessage = _extractMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  int _calculateAgeInYears(DateTime birthDate) {
    final now = DateTime.now();
    var ageInYears = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      ageInYears--;
    }
    return ageInYears;
  }

  String _extractMessage(Object error) {
    if (error is DioException) {
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
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'تعذر الاتصال بالخادم. تأكد من عنوان الـ API والإنترنت';
      }
      return error.message ?? 'حدث خطأ في الاتصال بالخادم';
    }
    if (error is ApiException) {
      return error.message;
    }
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  String? _normalizeEgyptPhoneNumber(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '+20$digits';
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      return '+20${digits.substring(1)}';
    }
    if (digits.length == 12 && digits.startsWith('20')) {
      return '+$digits';
    }
    if (digits.length == 14 && digits.startsWith('0020')) {
      return '+${digits.substring(2)}';
    }
    return null;
  }
}
