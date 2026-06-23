import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../models/auth_state.dart';

final authProvider = StateProvider<AuthState?>((ref) => null);

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authInitProvider = Provider<void>((ref) {
  final supabase = Supabase.instance.client;

  final session = supabase.auth.currentSession;
  if (session != null) {
    ref.read(authProvider.notifier).state = AuthState.fromSession(session);
  }

  final sub = supabase.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    ref.read(authProvider.notifier).state = session != null
        ? AuthState.fromSession(session)
        : null;
  });

  ref.onDispose(() => sub.cancel());
});
