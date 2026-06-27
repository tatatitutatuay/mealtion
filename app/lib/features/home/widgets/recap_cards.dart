import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';

class RecapCards extends StatelessWidget {
  const RecapCards({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final monthLabel = DateFormat('MMMM yyyy').format(lastMonth);
    final yearLabel = '${now.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recap', style: AppTypography.s2.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _card(context, 'Monthly Wrapped', monthLabel, Icons.auto_awesome_mosaic_outlined)),
              const SizedBox(width: AppSpacing.cardGap),
              Expanded(child: _card(context, 'Yearly Wrapped', yearLabel, Icons.auto_awesome_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recap coming soon!'), duration: Duration(seconds: 1)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
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
      ),
    );
  }
}
