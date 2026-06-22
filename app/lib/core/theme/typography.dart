import 'package:flutter/material.dart';

class AppTypography {
  static const _noto = 'NotoSansThai';
  static const _inter = 'Inter';

  // Headers
  static const h4 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 34 / 28,
  );
  static const h5 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 28 / 24,
  );

  // Section / Card titles
  static const s1 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 28 / 18,
  );
  static const s2 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 24 / 16,
  );

  // Body
  static const b1 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
  );
  static const b2 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 24 / 16,
  );

  // Small body
  static const b3 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
  );
  static const b4 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14,
  );

  // Captions
  static const b5 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16 / 12,
  );
  static const b6 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
  );

  // Chips / Badges
  static const c1 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14,
  );
  static const c2 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
  );
  static const c3 = TextStyle(
    fontFamily: _noto,
    fontWeight: FontWeight.w500,
    fontSize: 10,
    height: 14 / 10,
  );

  // Buttons (Inter)
  static const buttonGiant = TextStyle(
    fontFamily: _inter,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 24 / 18,
  );
  static const buttonLarge = TextStyle(
    fontFamily: _inter,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 20 / 16,
  );
  static const buttonMedium = TextStyle(
    fontFamily: _inter,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 16 / 14,
  );
  static const buttonSmall = TextStyle(
    fontFamily: _inter,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
  );

  /// Maps Figma text styles to Material TextTheme slots.
  static TextTheme get textTheme => const TextTheme(
    displayLarge: h4,
    displayMedium: h5,
    headlineLarge: s1,
    headlineMedium: s2,
    bodyLarge: b1,
    bodyMedium: b2,
    bodySmall: b3,
    titleLarge: b4,
    titleMedium: b5,
    titleSmall: b6,
    labelLarge: buttonLarge,
    labelMedium: buttonMedium,
    labelSmall: buttonSmall,
  );
}
