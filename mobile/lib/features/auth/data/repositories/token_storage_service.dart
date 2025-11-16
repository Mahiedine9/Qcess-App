import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    print('[TokenStorageService] ✅ Token saved');
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    print('[TokenStorage] 🔍 Token read: ${token != null ? "FOUND" : "NULL"}');
    return token;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
