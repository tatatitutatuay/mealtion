import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../../add_meal/screens/add_meal_sheet.dart';
import '../providers/main_shell_provider.dart';
import '../providers/home_provider.dart';
import '../../friends/providers/friends_providers.dart';
import '../../friends/providers/profile_provider.dart';
import 'home_screen.dart';
import '../../friends/screens/friends_screen.dart';
import 'gallery_screen.dart';
import 'profile_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  final _screens = const [
    HomeScreen(),
    FriendsScreen(),
    GalleryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainShellTabIndexProvider);

    // Invalidate providers when switching tabs for fresh data
    ref.listen(mainShellTabIndexProvider, (previous, next) {
      if (previous == next) return;
      switch (next) {
        case 0:
          ref.invalidate(homeDashboardProvider);
        case 1:
          ref.invalidate(friendsFeedProvider);
          ref.invalidate(friendsListProvider);
          ref.invalidate(pendingRequestsProvider);
          ref.invalidate(sentRequestsProvider);
        case 3:
          ref.invalidate(myProfileProvider);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Screens
          IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          // Floating nav bar + FAB overlaid on top
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingOverlay(ref: ref, currentIndex: currentIndex),
          ),
        ],
      ),
    );
  }
}

/// Combined floating nav bar + center plus button, overlaid via Stack
/// so BackdropFilter can blur the content behind it.
class _FloatingOverlay extends StatelessWidget {
  final WidgetRef ref;
  final int currentIndex;

  const _FloatingOverlay({required this.ref, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 16 + bottomPadding),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Nav bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  border: AppSpacing.cardBorder,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _navItem(Icons.home_outlined, 'Home', 0),
                    _navItem(Icons.people_outline, 'Friend', 1),
                    const SizedBox(width: 48),
                    _navItem(Icons.photo_library_outlined, 'Gallery', 2),
                    _navItem(Icons.person_outline, 'Profile', 3),
                  ],
                ),
              ),
            ),
          ),
          // Plus button (overlapping top center)
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () => AddMealSheet.show(context),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 67,
                    height: 67,
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      border: AppSpacing.cardBorder,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = currentIndex == index;
    return GestureDetector(
      onTap: () => ref.read(mainShellTabIndexProvider.notifier).state = index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: selected ? AppColors.textPrimary : AppColors.grey500),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.c3.copyWith(
              color: selected ? AppColors.textPrimary : AppColors.grey500,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
