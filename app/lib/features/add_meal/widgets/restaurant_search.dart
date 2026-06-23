import 'package:flutter/material.dart';

class RestaurantSearch extends StatefulWidget {
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
  State<RestaurantSearch> createState() => _RestaurantSearchState();
}

class _RestaurantSearchState extends State<RestaurantSearch> {
  late TextEditingController _restaurantController;
  late TextEditingController _branchController;

  @override
  void initState() {
    super.initState();
    _restaurantController = TextEditingController(text: widget.restaurant ?? '');
    _branchController = TextEditingController(text: widget.branch ?? '');
  }

  @override
  void didUpdateWidget(RestaurantSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restaurant != oldWidget.restaurant && widget.restaurant != _restaurantController.text) {
      _restaurantController.text = widget.restaurant ?? '';
    }
    if (widget.branch != oldWidget.branch && widget.branch != _branchController.text) {
      _branchController.text = widget.branch ?? '';
    }
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Restaurant',
            hintText: 'Search or create...',
            border: const OutlineInputBorder(),
            suffixIcon: widget.restaurant != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _restaurantController.clear();
                      widget.onRestaurantChanged(null);
                    },
                  )
                : null,
          ),
          controller: _restaurantController,
          onChanged: (v) => widget.onRestaurantChanged(v.isEmpty ? null : v),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: 'Branch (optional)',
            hintText: 'Search or create...',
            border: const OutlineInputBorder(),
            suffixIcon: widget.branch != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _branchController.clear();
                      widget.onBranchChanged(null);
                    },
                  )
                : null,
          ),
          controller: _branchController,
          onChanged: (v) => widget.onBranchChanged(v.isEmpty ? null : v),
        ),
      ],
    );
  }
}
