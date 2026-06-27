import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/home_data.dart';
import '../providers/main_shell_provider.dart';
import 'meal_detail_sheet.dart';

class RecentEntries extends ConsumerWidget {
  final List<HomeMealEntry> meals;

  const RecentEntries({super.key, required this.meals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recent', style: AppTypography.s2.copyWith(color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(mainShellTabIndexProvider.notifier).state = 2,
                child: Text('View All', style: AppTypography.c3.copyWith(
                    color: AppColors.textFaded, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...meals.map((meal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _mealCard(context, ref, meal),
          )),
        ],
      ),
    );
  }

  Widget _mealCard(BuildContext context, WidgetRef ref, HomeMealEntry meal) {
    return GestureDetector(
      onTap: () => MealDetailSheet.show(context, meal.id),
      child: Container(
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
                child: meal.thumbnailUrl != null
                    ? Image.network(meal.thumbnailUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.restaurant, color: AppColors.grey500),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.foods.join(', '),
                      style: AppTypography.s2.copyWith(
                          color: AppColors.textPrimary, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (meal.restaurantName != null)
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${meal.restaurantName}${meal.branchName != null ? ' (${meal.branchName})' : ''}',
                              style: AppTypography.b5.copyWith(
                                  color: AppColors.textSecondary, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (meal.price != null) ...[
                          _pillTag('${meal.price!.toStringAsFixed(0)}฿', AppColors.tagGreen),
                          const SizedBox(width: 6),
                        ],
                        if (meal.heaviness != null) ...[
                          _heavinessTag(meal.heaviness!),
                          const SizedBox(width: 6),
                        ],
                        if (meal.feeling != null)
                          _feelingTag(meal.feeling!),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => MealDetailSheet.showCollectionSelector(context, ref, meal.id),
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.bookmark_border, size: 18, color: AppColors.grey500),
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
