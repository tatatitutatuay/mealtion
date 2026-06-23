import 'package:flutter/material.dart';
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
          spacing: 8,
          runSpacing: 4,
          children: [
            ...widget.foods.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value.name),
                onDeleted: () => widget.onRemove(entry.key),
              );
            }),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Add food...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  isDense: true,
                ),
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
