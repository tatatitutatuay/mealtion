import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealtion/core/theme/colors.dart';

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
      case 'Affordable': return AppColors.success;
      case 'Moderate': return AppColors.warning;
      case 'Expensive': return AppColors.error;
      default: return AppColors.grey500;
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
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: '0.00',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          onChanged: (v) {
            final val = double.tryParse(v);
            widget.onChanged(val);
          },
        ),
        if (level != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _levelColor(level).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(level, style: TextStyle(color: _levelColor(level), fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text('Based on your thresholds', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }
}
