import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';

final restaurantSearchProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];
  final rows = await supabase
      .from('restaurants')
      .select('name')
      .eq('user_id', userId)
      .ilike('name', '%${query.trim()}%')
      .limit(5);
  return (rows as List<dynamic>).cast<Map<String, dynamic>>().map((r) => r['name'] as String).toList();
});

final branchSearchProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];
  final rows = await supabase
      .from('branches')
      .select('name')
      .eq('user_id', userId)
      .ilike('name', '%${query.trim()}%')
      .limit(5);
  return (rows as List<dynamic>).cast<Map<String, dynamic>>().map((r) => r['name'] as String).toList();
});

class RestaurantSearch extends ConsumerStatefulWidget {
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
  ConsumerState<RestaurantSearch> createState() => _RestaurantSearchState();
}

class _RestaurantSearchState extends ConsumerState<RestaurantSearch> {
  late TextEditingController _restaurantController;
  late TextEditingController _branchController;
  final _restaurantFocus = FocusNode();
  final _branchFocus = FocusNode();
  String _restaurantQuery = '';
  String _branchQuery = '';

  @override
  void initState() {
    super.initState();
    _restaurantController = TextEditingController(text: widget.restaurant ?? '');
    _branchController = TextEditingController(text: widget.branch ?? '');
    _restaurantQuery = widget.restaurant ?? '';
    _branchQuery = widget.branch ?? '';
  }

  @override
  void didUpdateWidget(RestaurantSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restaurant != oldWidget.restaurant && widget.restaurant != _restaurantController.text) {
      _restaurantController.text = widget.restaurant ?? '';
      _restaurantQuery = widget.restaurant ?? '';
    }
    if (widget.branch != oldWidget.branch && widget.branch != _branchController.text) {
      _branchController.text = widget.branch ?? '';
      _branchQuery = widget.branch ?? '';
    }
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _branchController.dispose();
    _restaurantFocus.dispose();
    _branchFocus.dispose();
    super.dispose();
  }

  Widget _suggestionsBox(List<String> suggestions, ValueChanged<String> onSelect) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView(
        shrinkWrap: true,
        children: suggestions
            .map((s) => ListTile(
                  dense: true,
                  title: Text(s),
                  onTap: () => onSelect(s),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantSuggestions = _restaurantFocus.hasFocus
        ? ref.watch(restaurantSearchProvider(_restaurantQuery)).valueOrNull ?? []
        : <String>[];
    final branchSuggestions = _branchFocus.hasFocus
        ? ref.watch(branchSearchProvider(_branchQuery)).valueOrNull ?? []
        : <String>[];

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
                      setState(() => _restaurantQuery = '');
                      widget.onRestaurantChanged(null);
                    },
                  )
                : null,
          ),
          controller: _restaurantController,
          focusNode: _restaurantFocus,
          onChanged: (v) {
            setState(() => _restaurantQuery = v);
            widget.onRestaurantChanged(v.isEmpty ? null : v);
          },
        ),
        if (_restaurantFocus.hasFocus && restaurantSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          _suggestionsBox(restaurantSuggestions, (s) {
            _restaurantController.text = s;
            setState(() => _restaurantQuery = s);
            widget.onRestaurantChanged(s);
            _restaurantFocus.unfocus();
          }),
        ],
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
                      setState(() => _branchQuery = '');
                      widget.onBranchChanged(null);
                    },
                  )
                : null,
          ),
          controller: _branchController,
          focusNode: _branchFocus,
          onChanged: (v) {
            setState(() => _branchQuery = v);
            widget.onBranchChanged(v.isEmpty ? null : v);
          },
        ),
        if (_branchFocus.hasFocus && branchSuggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          _suggestionsBox(branchSuggestions, (s) {
            _branchController.text = s;
            setState(() => _branchQuery = s);
            widget.onBranchChanged(s);
            _branchFocus.unfocus();
          }),
        ],
      ],
    );
  }
}
