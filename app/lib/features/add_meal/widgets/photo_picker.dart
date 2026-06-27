import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/add_meal_state.dart';

class PhotoPicker extends StatelessWidget {
  final List<AddMealPhoto> photos;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final ValueChanged<int> onRemove;

  const PhotoPicker({
    super.key,
    required this.photos,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Photos (${photos.length}/10)',
                style: AppTypography.s2.copyWith(
                    color: AppColors.textPrimary, fontSize: 16)),
            const Spacer(),
            if (photos.length < 10) ...[
              GestureDetector(
                onTap: onPickGallery,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    border: AppSpacing.cardBorder,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.photo_library_outlined,
                      size: 12, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onPickCamera,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    border: AppSpacing.cardBorder,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.camera_alt_outlined,
                      size: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (photos.isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: AppSpacing.cardBorder,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
            ),
            child: Center(
              child: Text('Add at least 1 photo',
                  style: AppTypography.b5.copyWith(color: AppColors.textFaded)),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
                      child: Image.file(
                        File(photos[index].localPath),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                          child: Text('Cover',
                              style: AppTypography.c3.copyWith(color: AppColors.white)),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: AppColors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        if (photos.isNotEmpty)
          Text('First photo is the cover. Drag to reorder.',
              style: AppTypography.c3.copyWith(color: AppColors.textFaded)),
      ],
    );
  }
}
