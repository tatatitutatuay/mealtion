import 'package:flutter/material.dart';

class TagInput extends StatefulWidget {
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
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.tags.contains(text)) {
      widget.onAdd(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
                decoration: const InputDecoration(
                  hintText: 'Add tag...',
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
