import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../core/supabase/supabase_client.dart';
import '../models/auth_state.dart';

final authProvider = StreamProvider<AuthState?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((authState) {
    final session = authState.session;
    if (session == null) return null;
    return AuthState(
      id: session.user.id,
      email: session.user.email ?? '',
      displayName: session.user.userMetadata?['display_name'] as String? ?? '',
      username: session.user.userMetadata?['username'] as String?,
      photoUrl: session.user.userMetadata?['photo_url'] as String?,
      onboardingCompleted: session.user.userMetadata?['onboarding_completed'] as bool? ?? false,
    );
  });
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return ref.watch(supabaseProvider);
});
