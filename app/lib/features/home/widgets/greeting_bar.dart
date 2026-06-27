import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';

class GreetingBar extends StatelessWidget {
  final String displayName;
  final String? photoUrl;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const GreetingBar({
    super.key,
    required this.displayName,
    this.photoUrl,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $displayName!',
                    style: AppTypography.s1.copyWith(
                        color: AppColors.textPrimary, fontSize: 20)),
                Text('How was your meal',
                    style: AppTypography.b5.copyWith(
                        color: AppColors.textPrimary, fontSize: 12)),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  width: 37,
                  height: 37,
                  decoration: const BoxDecoration(
                    border: AppSpacing.cardBorder,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.notifications_none_rounded,
                      size: 18, color: AppColors.textPrimary),
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.tagRed,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      notificationCount > 9 ? '9+' : '$notificationCount',
                      style: AppTypography.c3.copyWith(
                          color: AppColors.textPrimary, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
