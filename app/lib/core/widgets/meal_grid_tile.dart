import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';

class MealGridTile extends StatelessWidget {
  final String thumbnailUrl;
  final bool hasMultiplePhotos;
  final VoidCallback onTap;
  final double borderRadius;

  const MealGridTile({
    super.key,
    required this.thumbnailUrl,
    required this.onTap,
    this.hasMultiplePhotos = false,
    this.borderRadius = AppSpacing.radiusPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(thumbnailUrl, fit: BoxFit.cover),
            if (hasMultiplePhotos)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.collections, color: AppColors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
