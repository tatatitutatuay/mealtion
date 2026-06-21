import 'api_client.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final response = await _client.post('/auth/signup', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await _client.post('/auth/verify-email?token=$token');
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _client.post('/auth/forgot-password', data: {
      'email': email,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> deleteAccount(String password) async {
    final response = await _client.delete('/auth/account');
    return response.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.get('/auth/me');
    return response.data;
  }
}
