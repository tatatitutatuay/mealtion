import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import 'package:mealtion/core/widgets/circle_icon_button.dart';
import 'package:mealtion/core/widgets/meal_grid_tile.dart';
import 'package:mealtion/core/widgets/pill_button.dart';
import '../providers/gallery_provider.dart';
import '../widgets/meal_detail_sheet.dart';
import '../widgets/gallery_timeline.dart';
import '../../bookmarks/screens/bookmark_collections_screen.dart';
import 'gallery_search_screen.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isGridView = false;

  void _prevMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1));
  void _nextMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1));

  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(galleryProvider(_currentMonth));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: gallery.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.grey500),
                          const SizedBox(height: 12),
                          Text('No meals in ${DateFormat('MMMM yyyy').format(_currentMonth)}',
                              style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return _isGridView ? _gridView(items) : _timelineView(items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Column(
        children: [
          // Title + bookmark button
          Row(
            children: [
              Text('Gallery', style: AppTypography.s1.copyWith(
                  color: AppColors.textPrimary, fontSize: 20)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookmarkCollectionsScreen()),
                ),
                child: Container(
                  width: 37,
                  height: 37,
                  decoration: const BoxDecoration(
                    border: AppSpacing.cardBorder,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.bookmark_border, size: 16, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar (bordered)
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GallerySearchScreen()),
            ),
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: AppSpacing.cardBorder,
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 11, color: AppColors.textFaded),
                  const SizedBox(width: 10),
                  Text('Search meal', style: AppTypography.b5.copyWith(
                      color: const Color(0x4D000000), fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Month nav + view toggle
          Row(
            children: [
              CircleIconButton(icon: Icons.chevron_left, onTap: _prevMonth),
              const SizedBox(width: 5),
              PillButton(label: DateFormat('MMMM yyyy').format(_currentMonth)),
              const SizedBox(width: 5),
              CircleIconButton(icon: Icons.chevron_right, onTap: _nextMonth),
              const Spacer(),
              _viewToggle(),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _viewToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isGridView = !_isGridView),
      child: Container(
        height: 23,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_isGridView ? Icons.view_list_outlined : Icons.align_horizontal_left,
                size: 11, color: AppColors.textPrimary),
            const SizedBox(width: 10),
            const VerticalDivider(width: 1, thickness: 0.5, color: AppColors.border),
            const SizedBox(width: 10),
            Icon(_isGridView ? Icons.grid_view_outlined : Icons.table_rows_outlined,
                size: 12, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _gridView(List<GalleryItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => MealGridTile(
        thumbnailUrl: items[i].thumbnailUrl,
        hasMultiplePhotos: items[i].hasMultiplePhotos,
        onTap: () => MealDetailSheet.show(context, items[i].mealId),
      ),
    );
  }

  Widget _timelineView(List<GalleryItem> items) {
    return GalleryTimelineView(
      items: items,
      onTap: (item) => MealDetailSheet.show(context, item.mealId),
    );
  }
}
