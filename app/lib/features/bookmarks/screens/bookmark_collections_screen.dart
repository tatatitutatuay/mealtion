import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/bookmark_provider.dart';
import 'base_bookmark_detail_screen.dart';
import 'custom_collection_detail_screen.dart';

class BookmarkCollectionsScreen extends ConsumerWidget {
  const BookmarkCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(bookmarkCollectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.layoutMargin),
          children: [
            Text('Base', style: AppTypography.s2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _baseCard(context, 'Place', 'รวมสถานที่ที่คุณเคยบันทึก', Icons.place_outlined, () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const BaseBookmarkDetailScreen(category: 'Place'),
                  ));
                })),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(child: _baseCard(context, 'Food', 'รวมอาหารที่คุณเคยบันทึก', Icons.restaurant_outlined, () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const BaseBookmarkDetailScreen(category: 'Food'),
                  ));
                })),
              ],
            ),
            const SizedBox(height: 32),
            Text('Your', style: AppTypography.s2),
            const SizedBox(height: 12),
            collections.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No custom collections yet',
                          style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.cardGap,
                    mainAxisSpacing: AppSpacing.cardGap,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _customCard(context, list[i]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _baseCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.s2),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.b5.copyWith(color: AppColors.textSecondary), maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customCard(BuildContext context, BookmarkCollection collection) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CustomCollectionDetailScreen(collectionId: collection.id, collectionName: collection.name),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          image: collection.coverKey != null
              ? DecorationImage(image: NetworkImage(collection.coverKey!), fit: BoxFit.cover)
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(collection.name, style: AppTypography.s2.copyWith(color: AppColors.white)),
              Text('${collection.itemCount} items', style: AppTypography.b5.copyWith(color: AppColors.white)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Collection name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              try {
                await ref.read(bookmarkActionsProvider).createCollection(name);
                ref.invalidate(bookmarkCollectionsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
