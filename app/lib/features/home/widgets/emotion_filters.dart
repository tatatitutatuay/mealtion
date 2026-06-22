import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/typography.dart';

class EmotionFilters extends StatelessWidget {
  const EmotionFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot('Like', AppColors.success),
          const SizedBox(width: 24),
          _dot('Neutral', AppColors.warning),
          const SizedBox(width: 24),
          _dot('Dislike', AppColors.error),
        ],
      ),
    );
  }

  Widget _dot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.b5.copyWith(color: color)),
      ],
    );
  }
}
