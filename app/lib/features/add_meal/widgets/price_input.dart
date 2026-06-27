import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';

class PriceInput extends StatefulWidget {
  final double? price;
  final ValueChanged<double?> onChanged;

  const PriceInput({super.key, required this.price, required this.onChanged});

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.price?.toStringAsFixed(2) ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _calculateLevel(double price) {
    if (price <= 10) return 'Affordable';
    if (price <= 50) return 'Moderate';
    return 'Expensive';
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'Affordable': return AppColors.tagGreen;
      case 'Moderate': return AppColors.tagYellow;
      case 'Expensive': return AppColors.tagRed;
      default: return AppColors.grey100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.price;
    final level = price != null ? _calculateLevel(price) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: AppTypography.b5.copyWith(color: AppColors.textPrimary),
            hintText: '0.00',
            hintStyle: AppTypography.b5.copyWith(color: AppColors.textFaded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
          style: AppTypography.b5.copyWith(color: AppColors.textPrimary, fontSize: 12),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          onChanged: (v) {
            final val = double.tryParse(v);
            widget.onChanged(val);
          },
        ),
        if (level != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _levelColor(level),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                alignment: Alignment.center,
                child: Text(level,
                    style: AppTypography.b5.copyWith(
                        color: AppColors.textPrimary, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text('Based on your thresholds',
                  style: AppTypography.b5.copyWith(color: AppColors.textFaded, fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }
}
