import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../models/auth_state.dart';

final authProvider = StateProvider<AuthState?>((ref) => null);

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authInitProvider = Provider<void>((ref) {
  final supabase = Supabase.instance.client;

  // Defer initial state set — Riverpod forbids modifying other providers during build
  Future.microtask(() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      await _ensureProfile(supabase, session.user.id);
      final authState = await _fetchAuthState(supabase, session);
      ref.read(authProvider.notifier).state = authState;
    } else {
      ref.read(authProvider.notifier).state = null;
    }
  });

  final sub = supabase.auth.onAuthStateChange.listen((data) async {
    final session = data.session;
    if (session != null) {
      await _ensureProfile(supabase, session.user.id);
      final authState = await _fetchAuthState(supabase, session);
      ref.read(authProvider.notifier).state = authState;
    } else {
      ref.read(authProvider.notifier).state = null;
    }
  });

  ref.onDispose(() => sub.cancel());
});

/// Fetch full auth state from profiles table
Future<AuthState> _fetchAuthState(SupabaseClient supabase, Session session) async {
  try {
    final profile = await supabase
        .from('profiles')
        .select('id, display_name, username, photo_url, onboarding_completed, primary_currency, price_display_privacy, price_threshold_low, price_threshold_high')
        .eq('id', session.user.id)
        .maybeSingle();
    if (profile != null) {
      return AuthState(
        id: session.user.id,
        email: session.user.email ?? '',
        displayName: profile['display_name'] as String? ?? '',
        username: profile['username'] as String?,
        photoUrl: profile['photo_url'] as String?,
        onboardingCompleted: profile['onboarding_completed'] as bool? ?? false,
        primaryCurrency: profile['primary_currency'] as String? ?? 'USD',
        priceDisplayPrivacy: profile['price_display_privacy'] as String? ?? 'actual',
        priceThresholdLow: (profile['price_threshold_low'] as num?)?.toDouble() ?? 10.0,
        priceThresholdHigh: (profile['price_threshold_high'] as num?)?.toDouble() ?? 50.0,
      );
    }
  } catch (_) {}
  return AuthState.fromSession(session);
}

/// Insert a profile row if it doesn't exist yet (idempotent).
/// Does NOT overwrite existing fields on conflict.
Future<void> _ensureProfile(SupabaseClient supabase, String userId) async {
  try {
    await supabase.from('profiles').upsert({
      'id': userId,
      'display_name': '',
    }, onConflict: 'id', ignoreDuplicates: true);
  } catch (_) {
    // Ignore — profile may already exist or RLS may block; meal save will surface the real error
  }
}
