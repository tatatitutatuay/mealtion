import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFFF5A891);

  // Foundation Grey
  static const grey50 = Color(0xFFF8F8F8);
  static const grey100 = Color(0xFFEAEAEA);
  static const grey500 = Color(0xFFBBBBBB);
  static const grey900 = Color(0xFF4F4F4F);

  // Black & White
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  // Semantic
  static const success = Color(0xFF0EC760);
  static const warning = Color(0xFFFFAA0F);
  static const error = Color(0xFFFF3D00);

  // Semantic aliases for tags
  static const priceAffordable = success;
  static const priceModerate = warning;
  static const priceExpensive = error;
  static const heavinessLight = success;
  static const heavinessSatisfying = warning;
  static const heavinessHeavy = error;
  static const feelingLike = success;
  static const feelingNeutral = warning;
  static const feelingDislike = error;

  // Tag background colors (from Figma)
  static const tagGreen = Color(0xFFBDFFC1);
  static const tagYellow = Color(0xFFF0F8B0);
  static const tagRed = Color(0xFFFFAEAE);

  // Photo placeholder
  static const photoPlaceholder = Color(0xFFD9D9D9);

  // Border (for outlined card style)
  static const border = black;

  // Background
  static const background = grey50;
  static const surface = white;

  // Text
  static const textPrimary = black;
  static const textSecondary = grey900;
  static const textDisabled = grey500;
  static const textFaded = Color(0x80000000); // rgba(0,0,0,0.5)
}
