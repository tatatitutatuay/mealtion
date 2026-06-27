import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';

class ImagePickerSheet extends StatelessWidget {
  final String galleryLabel;
  final String cameraLabel;
  final String? removeLabel;
  final bool canRemove;
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback? onRemove;

  const ImagePickerSheet({
    super.key,
    required this.galleryLabel,
    required this.cameraLabel,
    this.removeLabel,
    this.canRemove = false,
    required this.onGallery,
    required this.onCamera,
    this.onRemove,
  });

  static void show({
    required BuildContext context,
    required String galleryLabel,
    required String cameraLabel,
    String? removeLabel,
    bool canRemove = false,
    required VoidCallback onGallery,
    required VoidCallback onCamera,
    VoidCallback? onRemove,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ImagePickerSheet(
        galleryLabel: galleryLabel,
        cameraLabel: cameraLabel,
        removeLabel: removeLabel,
        canRemove: canRemove,
        onGallery: () { Navigator.pop(ctx); onGallery(); },
        onCamera: () { Navigator.pop(ctx); onCamera(); },
        onRemove: onRemove != null ? () { Navigator.pop(ctx); onRemove(); } : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_outlined),
            title: Text(galleryLabel),
            onTap: onGallery,
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: Text(cameraLabel),
            onTap: onCamera,
          ),
          if (canRemove && removeLabel != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(removeLabel!),
              onTap: onRemove,
            ),
        ],
      ),
    );
  }
}
