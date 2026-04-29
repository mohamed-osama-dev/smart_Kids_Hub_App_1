import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../../../../core/services/session_service.dart';
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

  Future<bool> verifyOtp({
    required String verifyCode,
    bool isPasswordReset = false,
  }) async {
    if (sessionToken == null || sessionToken!.isEmpty) {
      errorMessage = 'Session token is missing';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      print('--- OTP DEBUG INFO ---');
      print('Session Token: $sessionToken');
      print('Cleaned OTP sent to API: "$verifyCode"');
      final data = await _repo.verifyOtp(
        sessionToken: sessionToken!,
        verifyCode: verifyCode,
      );
      if (isPasswordReset) {
        return true;
      }
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      if (accessToken == null || refreshToken == null) {
        throw ApiException('Invalid token response');
      }

      await SecureStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await SessionService.setLoggedIn(true);
      final userData = data['user'];
      final fullName =
          userData is Map ? userData['fullName']?.toString() ?? '' : '';
      if (fullName.isNotEmpty) {
        final existing = await SessionService.getParentInfo();
        await SessionService.saveParentInfo(
          fullName: fullName,
          phone: existing['phone'] ?? '',
        );
      }
      sessionToken = null;
      return true;
    } on DioException catch (e) {
      print('OTP VERIFY ERROR: ${e.response?.data}');
      errorMessage = _extractMessage(e);
      return false;
    } catch (e) {
      errorMessage = _extractMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addChild(Child child) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (child.weight == null || child.height == null) {
        throw ApiException('بيانات الطفل غير مكتملة');
      }
      final childId = await _repo.addChild(
        name: child.name,
        birthDate: child.birthDate,
        gender: child.gender,
        length: child.height!,
        weight: child.weight!,
      );
      await SecureStorageService.saveChildId(childId);
      return true;
    } on DioException catch (e) {
      print('ADD CHILD ERROR: ${e.response?.data}');
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors.first.toString();
        } else {
          final message = data['message']?.toString();
          errorMessage = (message != null && message.isNotEmpty)
              ? message
              : _extractMessage(e);
        }
      } else {
        errorMessage = _extractMessage(e);
      }
      return false;
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
      print('=== LOGIN RESPONSE DATA ===');
      print('Keys: ${data.keys.toList()}');
      print('Full data: $data');
      print('===========================');
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      if (accessToken == null || refreshToken == null) {
        throw ApiException('Invalid token response');
      }

      await SecureStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await SessionService.setLoggedIn(true);
      final userData = data['user'];
      final fullName =
          (userData is Map ? userData['fullName']?.toString() : null) ??
          data['fullName']?.toString() ??
          '';
      await SessionService.saveParentInfo(
        fullName: fullName,
        phone: normalizedPhone,
      );

      // Attempt to save childId if returned in login response
      final childIdRaw =
          data['childId'] ??
          data['ChildId'] ??
          (data['child'] != null ? (data['child']['id'] ?? data['child']['Id']) : null) ??
          (data['children'] is List && (data['children'] as List).isNotEmpty
              ? (data['children'] as List).first['id'] ?? (data['children'] as List).first['Id']
              : null);
      print('=== CHILD ID CHECK ===');
      print('childIdRaw: $childIdRaw');
      print('======================');
      if (childIdRaw != null) {
        final childId = childIdRaw is int
            ? childIdRaw
            : int.tryParse(childIdRaw.toString());
        if (childId != null) {
          await SecureStorageService.saveChildId(childId);
          print('✅ Child ID saved: $childId');
        }
      } else {
        print('⚠️ No childId found in login response!');
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

  Future<bool> forgotPassword({required String phoneNumber}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final normalizedPhone = _normalizeEgyptPhoneNumber(phoneNumber);
      if (normalizedPhone == null) {
        throw ApiException('رقم الهاتف غير صحيح');
      }
      sessionToken = await _repo.forgotPassword(phoneNumber: normalizedPhone);
      return true;
    } catch (e) {
      errorMessage = _extractMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setNewPassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (sessionToken == null || sessionToken!.isEmpty) {
      errorMessage = 'Session token is missing';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repo.setNewPassword(
        sessionToken: sessionToken!,
        password: password,
        confirmPassword: confirmPassword,
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

  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repo.logout();
    } catch (e) {
      errorMessage = _extractMessage(e);
    } finally {
      await SessionService.clearSession();
      await SessionService.saveParentInfo(fullName: '', phone: '');
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
