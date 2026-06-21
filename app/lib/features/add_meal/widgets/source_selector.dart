import 'package:flutter/material.dart';
import '../models/add_meal_state.dart';

class SourceSelector extends StatelessWidget {
  final MealSource source;
  final ValueChanged<MealSource> onChanged;

  const SourceSelector({
    super.key,
    required this.source,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<MealSource>(
      segments: const [
        ButtonSegment(value: MealSource.restaurant, label: Text('Restaurant'), icon: Icon(Icons.restaurant, size: 18)),
        ButtonSegment(value: MealSource.delivery, label: Text('Delivery'), icon: Icon(Icons.delivery_dining, size: 18)),
        ButtonSegment(value: MealSource.home, label: Text('Home'), icon: Icon(Icons.home, size: 18)),
      ],
      selected: {source},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
