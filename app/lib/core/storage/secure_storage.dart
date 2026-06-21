import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: 'refresh_token', value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: 'access_token');

  Future<String?> getRefreshToken() =>
      _storage.read(key: 'refresh_token');

  Future<void> clearAll() => _storage.deleteAll();
}
