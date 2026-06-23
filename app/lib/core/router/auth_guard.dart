import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

class AuthGuard {
  static Future<String?> redirect(Ref ref, GoRouterState state) async {
    final auth = ref.read(authProvider);
    final isLoggedIn = auth != null;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');
    final isOnboarding = state.matchedLocation.startsWith('/onboarding');

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth/login';
    }
    if (isLoggedIn && isAuthRoute) {
      if (!auth.onboardingCompleted) return '/onboarding';
      return '/';
    }
    if (isLoggedIn && !isOnboarding && !auth.onboardingCompleted) {
      return '/onboarding';
    }
    if (isLoggedIn && isOnboarding && auth.onboardingCompleted) {
      return '/';
    }
    return null;
  }
}
