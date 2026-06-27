import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../../../core/supabase/supabase_client.dart';

final tagSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];
  final rows = await supabase
      .from('meal_tags')
      .select('tag_name')
      .ilike('tag_name', '%${query.trim()}%')
      .limit(5);
  final names = (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => r['tag_name'] as String)
      .toSet()
      .toList();
  return names;
});

class TagInput extends ConsumerStatefulWidget {
  final List<String> tags;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const TagInput({
    super.key,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  ConsumerState<TagInput> createState() => _TagInputState();
}

class _TagInputState extends ConsumerState<TagInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.tags.contains(text)) {
      widget.onAdd(text);
      _controller.clear();
      setState(() => _query = '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _focusNode.hasFocus && _query.length >= 2
        ? ref.watch(tagSuggestionsProvider(_query)).valueOrNull ?? []
        : <String>[];
    final filtered = suggestions.where((s) => !widget.tags.contains(s)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...widget.tags.map((tag) {
              return GestureDetector(
                onTap: () => widget.onRemove(tag),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.tagYellow,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag,
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
                  hintText: 'Add tag...',
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
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
        if (filtered.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: filtered.map((s) => GestureDetector(
              onTap: () {
                widget.onAdd(s);
                _controller.clear();
                setState(() => _query = '');
              },
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: AppSpacing.cardBorder,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                alignment: Alignment.center,
                child: Text(s,
                    style: AppTypography.b5.copyWith(
                        color: AppColors.textPrimary, fontSize: 12)),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}
