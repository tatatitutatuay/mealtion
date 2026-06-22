import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(auth?.displayName ?? 'User'),
            const SizedBox(height: 8),
            Text(auth?.email ?? ''),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) context.go('/auth/login');
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
