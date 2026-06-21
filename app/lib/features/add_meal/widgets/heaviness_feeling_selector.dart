import 'package:flutter/material.dart';
import '../models/add_meal_state.dart';

class HeavinessFeelingSelector extends StatelessWidget {
  final Heaviness? heaviness;
  final Feeling? feeling;
  final ValueChanged<Heaviness?> onHeavinessChanged;
  final ValueChanged<Feeling?> onFeelingChanged;

  const HeavinessFeelingSelector({
    super.key,
    required this.heaviness,
    required this.feeling,
    required this.onHeavinessChanged,
    required this.onFeelingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Heaviness', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            _buildHeavinessOption('Light', Heaviness.light, Colors.green),
            _buildHeavinessOption('Satisfying', Heaviness.satisfying, Colors.orange),
            _buildHeavinessOption('Heavy', Heaviness.heavy, Colors.red),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Feeling', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            _buildFeelingOption('Like', Feeling.like, Colors.green),
            _buildFeelingOption('Neutral', Feeling.neutral, Colors.orange),
            _buildFeelingOption('Dislike', Feeling.dislike, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildHeavinessOption(String label, Heaviness value, Color color) {
    final selected = heaviness == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: selected ? const TextStyle(color: Colors.white) : null,
      selectedColor: color,
      onSelected: (_) => onHeavinessChanged(selected ? null : value),
    );
  }

  Widget _buildFeelingOption(String label, Feeling value, Color color) {
    final selected = feeling == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: selected ? const TextStyle(color: Colors.white) : null,
      selectedColor: color,
      onSelected: (_) => onFeelingChanged(selected ? null : value),
    );
  }
}
