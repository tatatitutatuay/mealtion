import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/add_meal_state.dart';

class HeavinessFeelingSelector extends StatelessWidget {
  final Heaviness? heaviness;
  final Feeling? feeling;
  final ValueChanged<Heaviness?> onHeavinessChanged;
  final ValueChanged<Feeling?> onFeelingChanged;

  const HeavinessFeelingSelector({
    super.key,
    required this.heaviness,
    required this.feeling,
    required this.onHeavinessChanged,
    required this.onFeelingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Heaviness', style: AppTypography.b5.copyWith(
            color: AppColors.textPrimary, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _pill('Healthy', Heaviness.light, AppColors.tagGreen, heaviness, onHeavinessChanged)),
            const SizedBox(width: 6),
            Expanded(child: _pill('Satisfying', Heaviness.satisfying, AppColors.tagYellow, heaviness, onHeavinessChanged)),
            const SizedBox(width: 6),
            Expanded(child: _pill('Heavy', Heaviness.heavy, AppColors.tagRed, heaviness, onHeavinessChanged)),
          ],
        ),
        const SizedBox(height: 12),
        Text('Feeling', style: AppTypography.b5.copyWith(
            color: AppColors.textPrimary, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _pill('Like', Feeling.like, AppColors.tagGreen, feeling, onFeelingChanged)),
            const SizedBox(width: 6),
            Expanded(child: _pill('Neutral', Feeling.neutral, AppColors.tagYellow, feeling, onFeelingChanged)),
            const SizedBox(width: 6),
            Expanded(child: _pill('Dislike', Feeling.dislike, AppColors.tagRed, feeling, onFeelingChanged)),
          ],
        ),
      ],
    );
  }

  Widget _pill<T>(String label, T value, Color color, T? selected, ValueChanged<T?> onChanged) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onChanged(isSelected ? null : value),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : null,
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTypography.b5.copyWith(
            color: AppColors.textPrimary, fontSize: 12)),
      ),
    );
  }
}
