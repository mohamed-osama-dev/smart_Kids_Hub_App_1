import 'package:shared_preferences/shared_preferences.dart';

import '../network/secure_storage_service.dart';

class SessionService {
  static const String _loggedInKey = 'session_logged_in';

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
}

