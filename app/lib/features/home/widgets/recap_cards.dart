import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/shadows.dart';
import 'package:mealtion/core/theme/typography.dart';

class RecapCards extends StatelessWidget {
  const RecapCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Row(
        children: [
          Expanded(child: _card('Monthly Wrapped', 'April 2026', Icons.auto_awesome_mosaic_outlined)),
          const SizedBox(width: AppSpacing.cardGap),
          Expanded(child: _card('Yearly Wrapped', '2026', Icons.auto_awesome_outlined)),
        ],
      ),
    );
  }

  Widget _card(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.s2.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
