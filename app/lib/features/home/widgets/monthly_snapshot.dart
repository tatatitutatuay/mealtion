import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';

class MonthlySnapshot extends StatelessWidget {
  final int totalMeals;
  final int totalFoods;
  final int totalRestaurants;
  final double totalSpent;

  const MonthlySnapshot({
    super.key,
    required this.totalMeals,
    required this.totalFoods,
    required this.totalRestaurants,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Snapshot', style: AppTypography.s2.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat('Meals', '$totalMeals'),
              const SizedBox(width: 8),
              _stat('Foods', '$totalFoods'),
              const SizedBox(width: 8),
              _stat('Place', '$totalRestaurants'),
              const SizedBox(width: 8),
              _stat('Spent (฿)', totalSpent.toStringAsFixed(0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.s2.copyWith(
                color: AppColors.textPrimary, fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.b5.copyWith(
                color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
