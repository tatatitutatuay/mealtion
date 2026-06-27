import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';

class PillButton extends StatelessWidget {
  final String label;

  const PillButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
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
}
