import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/gallery_provider.dart';
import '../widgets/meal_detail_sheet.dart';

class GallerySearchScreen extends ConsumerStatefulWidget {
  const GallerySearchScreen({super.key});

  @override
  ConsumerState<GallerySearchScreen> createState() => _GallerySearchScreenState();
}

class _GallerySearchScreenState extends ConsumerState<GallerySearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty ? null : ref.watch(gallerySearchProvider(_query));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search meal',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _query = v.trim()),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: results == null
                  ? Center(
                      child: Text('Search by food, restaurant, or tag',
                          style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                    )
                  : results.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (items) {
                        if (items.isEmpty) {
                          return Center(
                            child: Text('No results for "$_query"',
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
                          itemCount: items.length,
                          itemBuilder: (_, i) => _gridTile(items[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridTile(GalleryItem item) {
    return GestureDetector(
      onTap: () => MealDetailSheet.show(context, item.mealId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(item.thumbnailUrl, fit: BoxFit.cover),
            if (item.hasMultiplePhotos)
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
      ),
    );
  }
}
