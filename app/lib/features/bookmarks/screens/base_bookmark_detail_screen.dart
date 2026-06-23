import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/bookmark_provider.dart';

class BaseBookmarkDetailScreen extends ConsumerWidget {
  final String category;

  const BaseBookmarkDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = category == 'Place' ? basePlaceBookmarksProvider : baseFoodBookmarksProvider;
    final items = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
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
                  Text(category, style: AppTypography.s2),
                  const SizedBox(width: 8),
                  items.maybeWhen(
                    data: (list) => Text('${list.length} $category',
                        style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: items.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text('No $category bookmarks yet',
                          style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                    );
                  }

                  final grouped = <String, List<BaseBookmarkItem>>{};
                  for (final item in list) {
                    final letter = item.name[0].toUpperCase();
                    grouped.putIfAbsent(letter, () => []).add(item);
                  }
                  final sortedKeys = grouped.keys.toList()..sort();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 16),
                    itemCount: sortedKeys.length,
                    itemBuilder: (_, i) {
                      final letter = sortedKeys[i];
                      final group = grouped[letter]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(letter, style: AppTypography.s2.copyWith(color: AppColors.textSecondary)),
                          const Divider(height: 8),
                          ...group.map((item) => _itemRow(item)),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(BaseBookmarkItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.thumbnailUrl != null
                ? Image.network(item.thumbnailUrl!, width: 40, height: 40, fit: BoxFit.cover)
                : Container(
                    width: 40,
                    height: 40,
                    color: AppColors.grey100,
                    child: Icon(
                      category == 'Place' ? Icons.place_outlined : Icons.restaurant_outlined,
                      size: 20,
                      color: AppColors.grey500,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTypography.b4),
                if (item.subtitle != null)
                  Text(item.subtitle!, style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('${item.mealCount}', style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
