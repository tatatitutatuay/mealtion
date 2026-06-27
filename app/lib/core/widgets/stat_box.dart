import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool expanded;

  const StatBox({
    super.key,
    required this.label,
    required this.value,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: AppSpacing.cardBorder,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.s1.copyWith(
              color: AppColors.textPrimary, fontSize: 18)),
          Text(label, style: AppTypography.b5.copyWith(
              color: AppColors.textPrimary, fontSize: 12)),
        ],
      ),
    );
    return expanded ? Expanded(child: child) : child;
  }
}
