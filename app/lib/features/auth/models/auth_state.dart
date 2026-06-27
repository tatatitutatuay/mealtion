import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final String id;
  final String email;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final bool onboardingCompleted;
  final String primaryCurrency;
  final String priceDisplayPrivacy;
  final double priceThresholdLow;
  final double priceThresholdHigh;

  AuthState({
    required this.id,
    required this.email,
    required this.displayName,
    this.username,
    this.photoUrl,
    this.onboardingCompleted = false,
    this.primaryCurrency = 'USD',
    this.priceDisplayPrivacy = 'actual',
    this.priceThresholdLow = 10.0,
    this.priceThresholdHigh = 50.0,
  });

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String?,
      photoUrl: json['photo_url'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      primaryCurrency: json['primary_currency'] as String? ?? 'USD',
      priceDisplayPrivacy: json['price_display_privacy'] as String? ?? 'actual',
      priceThresholdLow: (json['price_threshold_low'] as num?)?.toDouble() ?? 10.0,
      priceThresholdHigh: (json['price_threshold_high'] as num?)?.toDouble() ?? 50.0,
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

  AuthState copyWith({
    String? displayName,
    String? username,
    String? photoUrl,
    bool? onboardingCompleted,
    String? primaryCurrency,
    String? priceDisplayPrivacy,
    double? priceThresholdLow,
    double? priceThresholdHigh,
  }) {
    return AuthState(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      priceDisplayPrivacy: priceDisplayPrivacy ?? this.priceDisplayPrivacy,
      priceThresholdLow: priceThresholdLow ?? this.priceThresholdLow,
      priceThresholdHigh: priceThresholdHigh ?? this.priceThresholdHigh,
    );
  }
}
