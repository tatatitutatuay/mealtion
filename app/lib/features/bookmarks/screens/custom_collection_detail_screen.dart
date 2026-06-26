import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/bookmark_provider.dart';

class CustomCollectionDetailScreen extends ConsumerWidget {
  final String collectionId;
  final String collectionName;

  const CustomCollectionDetailScreen({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(collectionMealsProvider(collectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showMenu(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 12),
              child: Row(
                children: [
                  Text(collectionName, style: AppTypography.s2),
                  const SizedBox(width: 8),
                  meals.maybeWhen(
                    data: (list) => Text('${list.length} Collections',
                        style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: meals.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text('No saved meals yet',
                          style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _gridTile(list[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridTile(CollectionMeal meal) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(meal.thumbnailUrl, fit: BoxFit.cover),
          if (meal.photoCount > 1)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.collections, color: AppColors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Collection'),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: edit collection name
              },
            ),
            ListTile(
              leading: const Icon(Icons.select_all_outlined),
              title: const Text('Select Items'),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: select items mode
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Collection', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('Delete Collection'),
                    content: Text('Delete "$collectionName"? This won\'t delete the original meals.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(d, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    await ref.read(bookmarkActionsProvider).deleteCollection(collectionId);
                    ref.invalidate(bookmarkCollectionsProvider);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
