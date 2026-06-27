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
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Grey banner + settings icon
                Stack(
                  children: [
                    Container(height: 222, width: double.infinity, color: const Color(0xFFAAAAAA)),
                    Positioned(
                      top: 16,
                      right: AppSpacing.layoutMargin,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                        child: const Icon(Icons.settings_outlined, size: 24, color: AppColors.textPrimary),
                      ),
                    ),
                    // Avatar overlapping
                    Positioned(
                      top: 158,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grey100,
                            image: data.photoUrl != null
                                ? DecorationImage(image: NetworkImage(data.photoUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: data.photoUrl == null
                              ? Center(child: Text(data.displayName[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 48, color: AppColors.grey500)))
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Name + bio
                Text(data.displayName, style: AppTypography.s1.copyWith(
                    color: AppColors.textPrimary, fontSize: 18)),
                if (data.bio != null && data.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(data.bio!, style: AppTypography.b5.copyWith(
                      color: AppColors.textPrimary, fontSize: 14)),
                ],
                const SizedBox(height: 16),
                // Edit + View Profile buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pillButton('Edit Profile', Icons.edit_outlined, () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    )),
                    const SizedBox(width: 10),
                    _pillButton('View Profile', Icons.visibility_outlined, () {
                      final userId = ref.read(authProvider)?.id;
                      if (userId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FriendProfileScreen(userId: userId)),
                        );
                      }
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                // 4 stat boxes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
                  child: Row(
                    children: [
                      _statBox('Meals', '${data.totalMeals}'),
                      const SizedBox(width: 10),
                      _statBox('Foods', '${data.monthFoods}'),
                      const SizedBox(width: 10),
                      _statBox('Place', '${data.monthRestaurants}'),
                      const SizedBox(width: 10),
                      _statBox('Friends', '${data.friendsCount}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Your Stat section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Stat', style: AppTypography.s2.copyWith(
                          color: AppColors.textPrimary, fontSize: 16)),
                      const SizedBox(height: 8),
                      // Food Personality card
                      _foodPersonalityCard(context),
                      const SizedBox(height: 10),
                      // Recap cards
                      Row(
                        children: [
                          Expanded(child: _recapCard(context, 'April 2026', Icons.auto_awesome_mosaic_outlined)),
                          const SizedBox(width: 10),
                          Expanded(child: _recapCard(context, '2026', Icons.auto_awesome_outlined)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Collection Badge card
                      _collectionBadgeCard(context),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Log out
                TextButton(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) context.go('/auth/login');
                  },
                  child: Text('Log Out',
                      style: AppTypography.buttonMedium.copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 120), // space for floating nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pillButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 7.5),
            Text(label, style: AppTypography.b5.copyWith(
                color: AppColors.textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.s1.copyWith(
                color: AppColors.textPrimary, fontSize: 18)),
            Text(label, style: AppTypography.b5.copyWith(
                color: AppColors.textPrimary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _foodPersonalityCard(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food personality details coming soon!'), duration: Duration(seconds: 1)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      border: AppSpacing.cardBorder,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text('Food Personality',
                        style: AppTypography.b5.copyWith(
                            color: AppColors.textPrimary, fontSize: 12)),
                  ),
                  const SizedBox(height: 10),
                  Text('Cafe Hopper', style: AppTypography.s1.copyWith(
                      color: AppColors.textPrimary, fontSize: 18)),
                  Text('สายคาเฟ่', style: AppTypography.b5.copyWith(
                      color: AppColors.textPrimary, fontSize: 14)),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                border: AppSpacing.cardBorder,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.coffee_outlined, size: 28, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recapCard(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label recap coming soon!'), duration: const Duration(seconds: 1)),
      ),
      child: Container(
        height: 179,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const Spacer(),
            Text(label, style: AppTypography.s2.copyWith(
                color: AppColors.textPrimary, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _collectionBadgeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection badges coming soon!'), duration: Duration(seconds: 1)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events_outlined, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Collection Badge', style: AppTypography.s2.copyWith(
                  color: AppColors.textPrimary, fontSize: 16)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }
}
