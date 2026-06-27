import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
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
        border: AppSpacing.cardBorder,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
      child: ListView(
        shrinkWrap: true,
        children: suggestions
            .map((s) => ListTile(
                  dense: true,
                  title: Text(s, style: AppTypography.b5.copyWith(
                      color: AppColors.textPrimary, fontSize: 12)),
                  onTap: () => onSelect(s),
                ))
            .toList(),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, bool hasValue, VoidCallback onClear) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.b5.copyWith(color: AppColors.textFaded, fontSize: 12),
      hintText: hint,
      hintStyle: AppTypography.b5.copyWith(color: AppColors.textFaded, fontSize: 12),
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
      suffixIcon: hasValue
          ? GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.clear, size: 16, color: AppColors.textFaded),
            )
          : null,
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
          decoration: _inputDecoration(
            'Restaurant', 'Search or create...',
            widget.restaurant != null, () {
              _restaurantController.clear();
              setState(() => _restaurantQuery = '');
              widget.onRestaurantChanged(null);
            },
          ),
          controller: _restaurantController,
          focusNode: _restaurantFocus,
          style: AppTypography.b5.copyWith(color: AppColors.textPrimary, fontSize: 12),
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
          decoration: _inputDecoration(
            'Branch (optional)', 'Search or create...',
            widget.branch != null, () {
              _branchController.clear();
              setState(() => _branchQuery = '');
              widget.onBranchChanged(null);
            },
          ),
          controller: _branchController,
          focusNode: _branchFocus,
          style: AppTypography.b5.copyWith(color: AppColors.textPrimary, fontSize: 12),
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
