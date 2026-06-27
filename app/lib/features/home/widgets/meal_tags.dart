import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';

class MealTags {
  static Widget pill(String label, Color bgColor) {
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

  static Widget price(num price) {
    return pill('${price.toStringAsFixed(0)}฿', AppColors.tagGreen);
  }

  static Widget heaviness(String heaviness) {
    final (label, color) = switch (heaviness) {
      'light' => ('Healthy', AppColors.tagGreen),
      'satisfying' => ('Satisfying', AppColors.tagYellow),
      'heavy' => ('Heavy', AppColors.tagRed),
      _ => (heaviness, AppColors.grey100),
    };
    return pill(label, color);
  }

  static Widget feeling(String feeling) {
    final (label, color) = switch (feeling) {
      'like' => ('Like', AppColors.tagGreen),
      'neutral' => ('Neutral', AppColors.tagYellow),
      'dislike' => ('Dislike', AppColors.tagRed),
      _ => (feeling, AppColors.grey100),
    };
    return pill(label, color);
  }
}
