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
              _stat('Foods', '$totalFoods'),
              _stat('Place', '$totalRestaurants'),
              _stat('Spent', '${totalSpent.toStringAsFixed(0)}฿'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.h5.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
