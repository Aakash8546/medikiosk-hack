import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  static const _keyToken = 'access_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyExpiry = 'token_expiry';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await _storage.write(key: _keyToken, value: accessToken);
    await _storage.write(key: _keyRefresh, value: refreshToken);
    await _storage.write(
      key: _keyExpiry,
      value: expiresAt.toIso8601String(),
    );
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _keyToken, value: accessToken);
  }

  Future<String?> getAccessToken() async => _storage.read(key: _keyToken);
  Future<String?> getRefreshToken() async => _storage.read(key: _keyRefresh);

  Future<bool> isTokenExpired() async {
    final expiryStr = await _storage.read(key: _keyExpiry);
    if (expiryStr == null) return true;
    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  Future<void> refreshAccessToken(String refreshToken) async {
    
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}