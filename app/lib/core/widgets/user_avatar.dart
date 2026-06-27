import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/typography.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String displayName;
  final double radius;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    required this.displayName,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.grey100,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(displayName[0].toUpperCase(), style: AppTypography.h5)
          : null,
    );
  }
}
