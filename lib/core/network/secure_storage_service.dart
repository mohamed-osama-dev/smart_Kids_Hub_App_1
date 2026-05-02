import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_kids_hub/core/services/hive_service.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _childIdKey = 'child_id';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessTokenKey);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  static Future<void> saveChildId(int childId) async {
    await _storage.write(key: _childIdKey, value: childId.toString());
  }

  static Future<int?> getChildId() async {
    final value = await _storage.read(key: _childIdKey);
    if (value != null) {
      return int.tryParse(value);
    }

    try {
      final children = HiveService.getCachedChildren();
      if (children.isNotEmpty) {
        final id = children.first.id;
        if (id > 0) {
          await saveChildId(id);
          return id;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
