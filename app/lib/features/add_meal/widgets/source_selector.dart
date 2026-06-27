import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/add_meal_state.dart';

class SourceSelector extends StatelessWidget {
  final MealSource source;
  final ValueChanged<MealSource> onChanged;

  const SourceSelector({
    super.key,
    required this.source,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill(MealSource.restaurant, Icons.restaurant, 'Restaurant'),
        const SizedBox(width: 6),
        _pill(MealSource.delivery, Icons.delivery_dining, 'Delivery'),
        const SizedBox(width: 6),
        _pill(MealSource.home, Icons.home, 'Home'),
      ],
    );
  }

  Widget _pill(MealSource value, IconData icon, String label) {
    final selected = source == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.tagGreen : null,
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.b5.copyWith(
                color: AppColors.textPrimary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
