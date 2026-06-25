import 'package:flutter/material.dart';

enum PriceLevel { cheap, moderate, expensive }

PriceLevel calculatePriceLevel(double price, double lowThreshold, double highThreshold) {
  if (price < lowThreshold) return PriceLevel.cheap;
  if (price < highThreshold) return PriceLevel.moderate;
  return PriceLevel.expensive;
}

extension PriceLevelX on PriceLevel {
  String get label => switch (this) {
        PriceLevel.cheap => 'Cheap',
        PriceLevel.moderate => 'Moderate',
        PriceLevel.expensive => 'Expensive',
      };

  Color get color => switch (this) {
        PriceLevel.cheap => const Color(0xFF4CAF50),
        PriceLevel.moderate => const Color(0xFFFF9800),
        PriceLevel.expensive => const Color(0xFFF44336),
      };

  IconData get icon => switch (this) {
        PriceLevel.cheap => Icons.arrow_downward,
        PriceLevel.moderate => Icons.drag_handle,
        PriceLevel.expensive => Icons.arrow_upward,
      };
}
