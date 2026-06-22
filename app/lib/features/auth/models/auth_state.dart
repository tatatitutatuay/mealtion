import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final String id;
  final String email;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final bool onboardingCompleted;

  AuthState({
    required this.id,
    required this.email,
    required this.displayName,
    this.username,
    this.photoUrl,
    this.onboardingCompleted = false,
  });

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String?,
      photoUrl: json['photo_url'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }

  factory AuthState.fromSession(Session session) {
    final user = session.user;
    final metadata = user.userMetadata;
    return AuthState(
      id: user.id,
      email: user.email ?? '',
      displayName: metadata?['display_name'] as String? ?? user.email?.split('@').first ?? '',
      username: metadata?['username'] as String?,
      photoUrl: metadata?['photo_url'] as String?,
      onboardingCompleted: metadata?['onboarding_completed'] as bool? ?? false,
    );
  }
}
