import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/gallery_provider.dart';
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
            const Divider(height: 1),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text('Gallery', style: AppTypography.h5),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookmarkCollectionsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GallerySearchScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.grey500),
                  const SizedBox(width: 8),
                  Text('Search meal', style: AppTypography.b3.copyWith(color: AppColors.grey500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth, visualDensity: VisualDensity.compact),
              Text(DateFormat('MMMM yyyy').format(_currentMonth), style: AppTypography.s2),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth, visualDensity: VisualDensity.compact),
              const Spacer(),
              _viewToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _viewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton(Icons.view_list_outlined, !_isGridView, () => setState(() => _isGridView = false)),
          _toggleButton(Icons.grid_view_outlined, _isGridView, () => setState(() => _isGridView = true)),
        ],
      ),
    );
  }

  Widget _toggleButton(IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
        ),
        child: Icon(icon, size: 16, color: selected ? AppColors.textPrimary : AppColors.grey500),
      ),
    );
  }

  Widget _gridView(List<GalleryItem> items) {
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
  }

  Widget _gridTile(GalleryItem item) {
    return ClipRRect(
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
    );
  }

  Widget _timelineView(List<GalleryItem> items) {
    final grouped = <String, List<GalleryItem>>{};
    for (final item in items) {
      final key = DateFormat('d MMM').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 16),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final entry = grouped.entries.elementAt(i);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(entry.key, style: AppTypography.s2.copyWith(color: AppColors.textSecondary)),
            ),
            ...entry.value.map((item) => _timelineCard(item)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _timelineCard(GalleryItem item) {
    final feelingColor = switch (item.feeling) {
      'like' => AppColors.success,
      'neutral' => AppColors.warning,
      'dislike' => AppColors.error,
      _ => AppColors.grey500,
    };
    final feelingLabel = switch (item.feeling) {
      'like' => 'Like',
      'neutral' => 'Neutral',
      'dislike' => 'Dislike',
      _ => '',
    };
    final heavinessLabel = switch (item.heaviness) {
      'light' => 'Light',
      'satisfying' => 'Satisfying',
      'heavy' => 'Heavy',
      _ => '',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusXs),
              bottomLeft: Radius.circular(AppSpacing.radiusXs),
            ),
            child: Image.network(item.thumbnailUrl, width: 90, height: 90, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.foods.join(', '), style: AppTypography.b4, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (item.restaurantName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${item.restaurantName}${item.branchName != null ? ' • ${item.branchName}' : ''}',
                      style: AppTypography.b5.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (item.price != null)
                        _chip('${item.price!.toStringAsFixed(0)} ฿', AppColors.grey100),
                      if (heavinessLabel.isNotEmpty)
                        _chip(heavinessLabel, AppColors.warning.withValues(alpha: 0.15)),
                      if (feelingLabel.isNotEmpty)
                        _chip(feelingLabel, feelingColor.withValues(alpha: 0.15)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
      ),
      child: Text(label, style: AppTypography.c3),
    );
  }
}
