import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import '../providers/bookmark_provider.dart';

class CollectionNameDialog extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String? initialName;
  final Future<void> Function(String name) onSubmit;

  const CollectionNameDialog._({
    required this.title,
    required this.submitLabel,
    this.initialName,
    required this.onSubmit,
  });

  static void showRename({
    required BuildContext context,
    required WidgetRef ref,
    required String collectionId,
    required String currentName,
    required VoidCallback onRenamed,
  }) {
    showDialog(
      context: context,
      builder: (_) => CollectionNameDialog._(
        title: 'Rename Collection',
        submitLabel: 'Save',
        initialName: currentName,
        onSubmit: (name) async {
          await ref.read(bookmarkActionsProvider).renameCollection(collectionId, name);
          onRenamed();
        },
      ),
    );
  }

  static void showCreate({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback onCreated,
  }) {
    showDialog(
      context: context,
      builder: (_) => CollectionNameDialog._(
        title: 'New Collection',
        submitLabel: 'Create',
        onSubmit: (name) async {
          await ref.read(bookmarkActionsProvider).createCollection(name);
          onCreated();
        },
      ),
    );
  }

  @override
  State<CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<CollectionNameDialog> {
  late final TextEditingController _controller;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initialName ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || name == widget.initialName) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Collection name'),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.submitLabel),
        ),
      ],
    );
  }
}
