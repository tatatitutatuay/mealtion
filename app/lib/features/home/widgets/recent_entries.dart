import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/shadows.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/home_data.dart';

class RecentEntries extends StatelessWidget {
  final List<HomeMealEntry> meals;

  const RecentEntries({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent entries', style: AppTypography.s2.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...meals.map((meal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _mealCard(meal),
          )),
        ],
      ),
    );
  }

  Widget _mealCard(HomeMealEntry meal) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusXs),
              bottomLeft: Radius.circular(AppSpacing.radiusXs),
            ),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.grey100,
              child: meal.thumbnailUrl != null
                  ? Image.network(meal.thumbnailUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.restaurant, color: AppColors.grey500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.foods.join(', '),
                    style: AppTypography.s2.copyWith(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (meal.restaurantName != null)
                    Text(
                      '${meal.restaurantName}${meal.branchName != null ? ' (${meal.branchName})' : ''}',
                      style: AppTypography.b5.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (meal.price != null)
                        Text('${meal.price!.toStringAsFixed(0)} ฿',
                            style: AppTypography.b6.copyWith(color: AppColors.textPrimary)),
                      if (meal.price != null && meal.feeling != null)
                        const SizedBox(width: 8),
                      if (meal.feeling != null)
                        _feelingTag(meal.feeling!),
                      const Spacer(),
                      const Icon(Icons.bookmark_border, size: 16, color: AppColors.grey500),
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

  Widget _feelingTag(String feeling) {
    final (label, color) = switch (feeling) {
      'like' => ('Like', AppColors.success),
      'neutral' => ('Neutral', AppColors.warning),
      'dislike' => ('Dislike', AppColors.error),
      _ => (feeling, AppColors.grey500),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
      ),
      child: Text(label, style: AppTypography.c3.copyWith(color: color)),
    );
  }
}
