import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          spacing: 8,
          runSpacing: 4,
          children: [
            ...widget.tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => widget.onRemove(tag),
              );
            }),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Add tag...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
        if (filtered.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: filtered.map((s) => ActionChip(
              label: Text(s),
              onPressed: () {
                widget.onAdd(s);
                _controller.clear();
                setState(() => _query = '');
              },
            )).toList(),
          ),
        ],
      ],
    );
  }
}
