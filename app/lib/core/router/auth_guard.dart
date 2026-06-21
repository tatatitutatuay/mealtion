import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';

class AuthGuard {
  static Future<String?> redirect(Ref ref, GoRouterState state) async {
    final authAsync = ref.read(authProvider);
    final isLoggedIn = authAsync.valueOrNull != null;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth/login';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/';
    }
    return null;
  }
}
