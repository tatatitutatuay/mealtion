import 'package:flutter/material.dart';

class RestaurantSearch extends StatelessWidget {
  final String? restaurant;
  final String? branch;
  final ValueChanged<String?> onRestaurantChanged;
  final ValueChanged<String?> onBranchChanged;

  const RestaurantSearch({
    super.key,
    required this.restaurant,
    required this.branch,
    required this.onRestaurantChanged,
    required this.onBranchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Restaurant',
            hintText: 'Search or create...',
            border: const OutlineInputBorder(),
            suffixIcon: restaurant != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => onRestaurantChanged(null),
                  )
                : null,
          ),
          controller: TextEditingController(text: restaurant ?? ''),
          onChanged: (v) => onRestaurantChanged(v.isEmpty ? null : v),
          onSubmitted: (v) {
            if (v.isNotEmpty) onRestaurantChanged(v);
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: 'Branch (optional)',
            hintText: 'Search or create...',
            border: const OutlineInputBorder(),
            suffixIcon: branch != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => onBranchChanged(null),
                  )
                : null,
          ),
          controller: TextEditingController(text: branch ?? ''),
          onChanged: (v) => onBranchChanged(v.isEmpty ? null : v),
          onSubmitted: (v) {
            if (v.isNotEmpty) onBranchChanged(v);
          },
        ),
      ],
    );
  }
}
