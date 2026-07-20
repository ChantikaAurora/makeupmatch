import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _userNamaKey = 'user_nama';
  static const _userEmailKey = 'user_email';

  // Token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // User
  static Future<void> saveUser({
    required String id,
    required String nama,
    required String email,
  }) async {
    await _storage.write(key: _userIdKey, value: id);
    await _storage.write(key: _userNamaKey, value: nama);
    await _storage.write(key: _userEmailKey, value: email);
  }

  static Future<Map<String, String?>> getUser() async {
    return {
      'id': await _storage.read(key: _userIdKey),
      'nama': await _storage.read(key: _userNamaKey),
      'email': await _storage.read(key: _userEmailKey),
    };
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}