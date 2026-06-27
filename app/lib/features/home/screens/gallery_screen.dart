import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/gallery_provider.dart';
import '../widgets/meal_detail_sheet.dart';
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
              _circleButton(Icons.chevron_left, _prevMonth),
              const SizedBox(width: 5),
              _pillButton(DateFormat('MMMM yyyy').format(_currentMonth)),
              const SizedBox(width: 5),
              _circleButton(Icons.chevron_right, _nextMonth),
              const Spacer(),
              _viewToggle(),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 23,
        height: 23,
        decoration: const BoxDecoration(
          border: AppSpacing.cardBorder,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _pillButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: AppSpacing.cardBorder,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
      child: Text(label, style: AppTypography.b5.copyWith(
          color: AppColors.textPrimary, fontSize: 12)),
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
      itemBuilder: (_, i) => _gridTile(items[i]),
    );
  }

  Widget _gridTile(GalleryItem item) {
    return GestureDetector(
      onTap: () => MealDetailSheet.show(context, item.mealId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
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

  Widget _timelineView(List<GalleryItem> items) {
    final grouped = <String, List<GalleryItem>>{};
    for (final item in items) {
      final key = DateFormat('d MMM').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.layoutMargin, 16, AppSpacing.layoutMargin, 120),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final entry = grouped.entries.elementAt(i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date column
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Text(entry.key.split(' ').first,
                        style: AppTypography.b5.copyWith(
                            color: AppColors.textPrimary, fontSize: 12)),
                    Text(entry.key.split(' ').last,
                        style: AppTypography.b5.copyWith(
                            color: AppColors.textPrimary, fontSize: 12)),
                  ],
                ),
              ),
              // Vertical line
              Container(width: 0.5, margin: const EdgeInsets.only(right: 8), color: AppColors.border),
              // Cards
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.value.map((item) => _timelineCard(item)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timelineCard(GalleryItem item) {
    return GestureDetector(
      onTap: () => MealDetailSheet.show(context, item.mealId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusPhoto),
                bottomLeft: Radius.circular(AppSpacing.radiusPhoto),
              ),
              child: Container(
                width: 90,
                height: 90,
                color: AppColors.photoPlaceholder,
                child: Image.network(item.thumbnailUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.foods.join(', '),
                        style: AppTypography.s2.copyWith(
                            color: AppColors.textPrimary, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (item.restaurantName != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item.restaurantName}${item.branchName != null ? ' (${item.branchName})' : ''}',
                              style: AppTypography.b5.copyWith(
                                  color: AppColors.textSecondary, fontSize: 12),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.price != null) ...[
                          _pillTag('${item.price!.toStringAsFixed(0)}฿', AppColors.tagGreen),
                          const SizedBox(width: 6),
                        ],
                        if (item.heaviness != null) ...[
                          _heavinessTag(item.heaviness!),
                          const SizedBox(width: 6),
                        ],
                        if (item.feeling != null)
                          _feelingTag(item.feeling!),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillTag(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(label, style: AppTypography.c3.copyWith(
          color: AppColors.textPrimary, fontSize: 10)),
    );
  }

  Widget _heavinessTag(String heaviness) {
    final (label, color) = switch (heaviness) {
      'light' => ('Healthy', AppColors.tagGreen),
      'satisfying' => ('Satisfying', AppColors.tagYellow),
      'heavy' => ('Heavy', AppColors.tagRed),
      _ => (heaviness, AppColors.grey100),
    };
    return _pillTag(label, color);
  }

  Widget _feelingTag(String feeling) {
    final (label, color) = switch (feeling) {
      'like' => ('Like', AppColors.tagGreen),
      'neutral' => ('Neutral', AppColors.tagYellow),
      'dislike' => ('Dislike', AppColors.tagRed),
      _ => (feeling, AppColors.grey100),
    };
    return _pillTag(label, color);
  }
}
