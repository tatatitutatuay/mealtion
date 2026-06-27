import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/gallery_provider.dart';
import 'meal_tags.dart';

class GalleryTimelineView extends StatelessWidget {
  final List<GalleryItem> items;
  final void Function(GalleryItem item) onTap;
  final bool showTags;

  const GalleryTimelineView({
    super.key,
    required this.items,
    required this.onTap,
    this.showTags = true,
  });

  @override
  Widget build(BuildContext context) {
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
              Container(width: 0.5, margin: const EdgeInsets.only(right: 8), color: AppColors.border),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.value.map((item) => _TimelineCard(
                    item: item,
                    onTap: () => onTap(item),
                    showTags: showTags,
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onTap;
  final bool showTags;

  const _TimelineCard({
    required this.item,
    required this.onTap,
    required this.showTags,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                    if (showTags) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (item.price != null) ...[
                            MealTags.price(item.price!),
                            const SizedBox(width: 6),
                          ],
                          if (item.heaviness != null) ...[
                            MealTags.heaviness(item.heaviness!),
                            const SizedBox(width: 6),
                          ],
                          if (item.feeling != null)
                            MealTags.feeling(item.feeling!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
