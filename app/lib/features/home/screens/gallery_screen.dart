import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/gallery_provider.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gallery = ref.watch(galleryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: gallery.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No photos yet'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.layoutMargin),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => _gridItem(items[i]),
          );
        },
      ),
    );
  }

  Widget _gridItem(GalleryItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          image: NetworkImage(item.thumbnailUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(4),
        child: Text(
          item.foods.first.length > 10
              ? '${item.foods.first.substring(0, 10)}...'
              : item.foods.first,
          style: AppTypography.c3.copyWith(color: Colors.white, shadows: [
            Shadow(color: Colors.black54, blurRadius: 4),
          ]),
        ),
      ),
    );
  }
}
