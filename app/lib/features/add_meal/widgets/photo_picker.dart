import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
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
            Text('Photos (${photos.length}/10)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const Spacer(),
            if (photos.length < 10) ...[
              IconButton(
                icon: const Icon(Icons.photo_library_outlined),
                tooltip: 'Gallery',
                onPressed: onPickGallery,
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                tooltip: 'Camera',
                onPressed: onPickCamera,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (photos.isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Add at least 1 photo',
                style: TextStyle(color: AppColors.grey500),
              ),
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
                      borderRadius: BorderRadius.circular(8),
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
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Cover', style: TextStyle(color: AppColors.white, fontSize: 10)),
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
              style: TextStyle(color: AppColors.grey500, fontSize: 12)),
      ],
    );
  }
}
