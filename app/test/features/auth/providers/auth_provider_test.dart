import 'package:flutter_test/flutter_test.dart';
import 'package:mealtion/features/auth/models/auth_state.dart';

// Tests will use mocktail to mock AuthApi and SecureStorage
void main() {
  test('AuthState fromJson parses correctly', () {
    final json = {
      'id': '123',
      'email': 'test@test.com',
      'display_name': 'Test User',
      'username': 'testuser',
      'photo_url': null,
      'onboarding_completed': false,
    };
    final state = AuthState.fromJson(json);
    expect(state.id, '123');
    expect(state.email, 'test@test.com');
    expect(state.displayName, 'Test User');
    expect(state.username, 'testuser');
    expect(state.onboardingCompleted, false);
  });
}
