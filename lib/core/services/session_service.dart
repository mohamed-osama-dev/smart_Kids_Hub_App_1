import 'package:shared_preferences/shared_preferences.dart';

import '../network/secure_storage_service.dart';

class SessionService {
  static const String _loggedInKey = 'session_logged_in';
  static const String _parentFullNameKey = 'parent_full_name';
  static const String _parentPhoneKey = 'parent_phone';

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInFlag = prefs.getBool(_loggedInKey) ?? false;
    if (!loggedInFlag) return false;

    final accessToken = await SecureStorageService.getAccessToken();
    final hasValidToken = accessToken != null && accessToken.isNotEmpty;
    if (!hasValidToken) {
      await setLoggedIn(false);
      return false;
    }

    return true;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    await SecureStorageService.clearAll();
  }

  static Future<void> saveParentInfo({
    required String fullName,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_parentFullNameKey, fullName);
    await prefs.setString(_parentPhoneKey, phone);
  }

  static Future<Map<String, String?>> getParentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString(_parentFullNameKey),
      'phone': prefs.getString(_parentPhoneKey),
    };
  }
}

