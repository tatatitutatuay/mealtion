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
    }
    ref.read(authProvider.notifier).state = session != null
        ? AuthState.fromSession(session)
        : null;
  });

  final sub = supabase.auth.onAuthStateChange.listen((data) async {
    final session = data.session;
    if (session != null) {
      await _ensureProfile(supabase, session.user.id);
    }
    ref.read(authProvider.notifier).state = session != null
        ? AuthState.fromSession(session)
        : null;
  });

  ref.onDispose(() => sub.cancel());
});

/// Insert a profile row if it doesn't exist yet (idempotent).
Future<void> _ensureProfile(SupabaseClient supabase, String userId) async {
  try {
    await supabase.from('profiles').upsert({
      'id': userId,
      'display_name': '',
    }, onConflict: 'id');
  } catch (_) {
    // Ignore — profile may already exist or RLS may block; meal save will surface the real error
  }
}
