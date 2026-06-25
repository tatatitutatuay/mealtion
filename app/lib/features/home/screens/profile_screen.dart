import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/profile_provider.dart';
import '../../friends/screens/friend_profile_screen.dart';
import '../../profile/screens/edit_profile_screen.dart';
import '../../profile/screens/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusXs),
                    bottomRight: Radius.circular(AppSpacing.radiusXs),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -48),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.grey100,
                  backgroundImage: data.photoUrl != null ? NetworkImage(data.photoUrl!) : null,
                  child: data.photoUrl == null
                      ? Text(data.displayName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32, color: AppColors.grey500))
                      : null,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Column(
                  children: [
                    Text(data.displayName, style: AppTypography.h5),
                    if (data.username != null) ...[
                      const SizedBox(height: 4),
                      Text('@${data.username}',
                          style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                    ],
                    if (data.bio != null && data.bio!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(data.bio!, style: AppTypography.b3, textAlign: TextAlign.center),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 140,
                          child: OutlinedButton(
                            onPressed: () {
                              final userId = ref.read(authProvider)?.id;
                              if (userId != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => FriendProfileScreen(userId: userId)),
                                );
                              }
                            },
                            child: const Text('View Profile'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stat('Meals', '${data.totalMeals}'),
                        const SizedBox(width: 48),
                        _stat('Foods', '${data.monthFoods}'),
                        const SizedBox(width: 48),
                        _stat('Place', '${data.monthRestaurants}'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) context.go('/auth/login');
                      },
                      child: Text('Log Out',
                          style: AppTypography.buttonMedium.copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.h5.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
