import 'package:flutter/material.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/add_meal_state.dart';

class FoodChips extends StatefulWidget {
  final List<AddMealFood> foods;
  final Function(String) onAdd;
  final Function(int) onRemove;

  const FoodChips({
    super.key,
    required this.foods,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<FoodChips> createState() => _FoodChipsState();
}

class _FoodChipsState extends State<FoodChips> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.foods.any((f) => f.name == text)) {
      widget.onAdd(text);
      _controller.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _submit();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...widget.foods.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => widget.onRemove(entry.key),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.tagGreen,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.value.name,
                          style: AppTypography.b5.copyWith(
                              color: AppColors.textPrimary, fontSize: 12)),
                      const SizedBox(width: 6),
                      const Icon(Icons.close, size: 12, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Add food...',
                  hintStyle: AppTypography.c3.copyWith(color: AppColors.textFaded),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  isDense: true,
                ),
                style: AppTypography.b5.copyWith(
                    color: AppColors.textPrimary, fontSize: 12),
                onSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
