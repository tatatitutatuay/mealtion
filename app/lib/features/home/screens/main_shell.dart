import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import '../../add_meal/screens/add_meal_sheet.dart';
import '../providers/main_shell_provider.dart';
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

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, ref, Icons.home_outlined, 'Home', 0),
            _navItem(context, ref, Icons.people_outline, 'Friends', 1),
            const SizedBox(width: 48),
            _navItem(context, ref, Icons.photo_library_outlined, 'Gallery', 2),
            _navItem(context, ref, Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddMealSheet.show(context),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _navItem(BuildContext context, WidgetRef ref, IconData icon, String label, int index) {
    final currentIndex = ref.watch(mainShellTabIndexProvider);
    final selected = currentIndex == index;
    return InkWell(
      onTap: () => ref.read(mainShellTabIndexProvider.notifier).state = index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : AppColors.grey500),
            Text(label, style: TextStyle(
              fontSize: 11,
              color: selected ? Theme.of(context).colorScheme.primary : AppColors.grey500,
            )),
          ],
        ),
      ),
    );
  }
}
