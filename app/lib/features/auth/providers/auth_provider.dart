import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/auth_api.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_state.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: ref.read(secureStorageProvider));
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(apiClientProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState?>((ref) {
  return AuthNotifier(
    authApi: ref.read(authApiProvider),
    storage: ref.read(secureStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState?> {
  final AuthApi _authApi;
  final SecureStorage _storage;

  AuthNotifier({required AuthApi authApi, required SecureStorage storage})
      : _authApi = authApi,
        _storage = storage,
        super(null);

  Future<void> signup(String email, String password) async {
    await _authApi.signup(email, password);
  }

  Future<void> verifyEmail(String token) async {
    await _authApi.verifyEmail(token);
  }

  Future<bool> login(String email, String password) async {
    final response = await _authApi.login(email, password);
    final data = response['data'] as Map<String, dynamic>;
    await _storage.saveAccessToken(data['access_token'] as String);
    await _storage.saveRefreshToken(data['refresh_token'] as String);
    state = AuthState.fromJson(data['user'] as Map<String, dynamic>);
    return true;
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = null;
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.getAccessToken();
    if (token == null) return false;
    try {
      final response = await _authApi.getMe();
      final data = response['data'] as Map<String, dynamic>;
      state = AuthState.fromJson(data);
      return true;
    } catch (_) {
      await _storage.clearAll();
      return false;
    }
  }
}
