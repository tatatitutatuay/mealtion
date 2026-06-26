import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/bookmark_provider.dart';
import 'base_bookmark_detail_screen.dart';
import 'custom_collection_detail_screen.dart';

class BookmarkCollectionsScreen extends ConsumerStatefulWidget {
  const BookmarkCollectionsScreen({super.key});

  @override
  ConsumerState<BookmarkCollectionsScreen> createState() => _BookmarkCollectionsScreenState();
}

class _BookmarkCollectionsScreenState extends ConsumerState<BookmarkCollectionsScreen> {
  bool _selectMode = false;
  final Set<String> _selected = {};

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selected.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final actions = ref.read(bookmarkActionsProvider);
    try {
      for (final id in _selected) {
        await actions.deleteCollection(id);
      }
      ref.invalidate(bookmarkCollectionsProvider);
      _exitSelectMode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _renameCollection(BookmarkCollection collection) async {
    await showDialog(
      context: context,
      builder: (ctx) => _RenameCollectionDialog(
        collection: collection,
        ref: ref,
        onRenamed: () {
          ref.invalidate(bookmarkCollectionsProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(bookmarkCollectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectMode ? '${_selected.length} selected' : 'Bookmark'),
        actions: [
          if (_selectMode) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _selected.length == 1
                  ? () {
                      final id = _selected.first;
                      final list = collections.valueOrNull ?? [];
                      final col = list.where((c) => c.id == id).firstOrNull;
                      if (col != null) _renameCollection(col);
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _selected.isNotEmpty ? _deleteSelected : null,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitSelectMode,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _selectMode = true),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateDialog(context, ref),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.layoutMargin),
          children: [
            const Text('Base', style: AppTypography.s2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _baseCard(context, 'Place', 'รวมสถานที่ที่คุณเคยบันทึก', Icons.place_outlined, () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const BaseBookmarkDetailScreen(category: 'Place'),
                  ));
                })),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(child: _baseCard(context, 'Food', 'รวมอาหารที่คุณเคยบันทึก', Icons.restaurant_outlined, () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const BaseBookmarkDetailScreen(category: 'Food'),
                  ));
                })),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Your', style: AppTypography.s2),
            const SizedBox(height: 12),
            collections.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No custom collections yet',
                          style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.cardGap,
                    mainAxisSpacing: AppSpacing.cardGap,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _customCard(context, list[i]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _baseCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.s2),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.b5.copyWith(color: AppColors.textSecondary), maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customCard(BuildContext context, BookmarkCollection collection) {
    final isSelected = _selected.contains(collection.id);
    return GestureDetector(
      onTap: _selectMode
          ? () => _toggleSelect(collection.id)
          : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CustomCollectionDetailScreen(collectionId: collection.id, collectionName: collection.name),
              )),
      onLongPress: () {
        if (!_selectMode) {
          setState(() {
            _selectMode = true;
            _selected.add(collection.id);
          });
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              image: collection.coverKey != null
                  ? DecorationImage(image: NetworkImage(collection.coverKey!), fit: BoxFit.cover)
                  : null,
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 3)
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(collection.name, style: AppTypography.s2.copyWith(color: AppColors.white)),
                  Text('${collection.itemCount} items', style: AppTypography.b5.copyWith(color: AppColors.white)),
                ],
              ),
            ),
          ),
          if (_selectMode)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _CreateCollectionDialog(ref: ref, onCreated: () {
        ref.invalidate(bookmarkCollectionsProvider);
      }),
    );
  }
}

class _RenameCollectionDialog extends StatefulWidget {
  final BookmarkCollection collection;
  final WidgetRef ref;
  final VoidCallback onRenamed;

  const _RenameCollectionDialog({
    required this.collection,
    required this.ref,
    required this.onRenamed,
  });

  @override
  State<_RenameCollectionDialog> createState() => _RenameCollectionDialogState();
}

class _RenameCollectionDialogState extends State<_RenameCollectionDialog> {
  late final TextEditingController _controller;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.collection.name);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty || newName == widget.collection.name) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.ref.read(bookmarkActionsProvider).renameCollection(widget.collection.id, newName);
      widget.onRenamed();
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
      title: const Text('Rename Collection'),
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
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _CreateCollectionDialog extends StatefulWidget {
  final WidgetRef ref;
  final VoidCallback onCreated;

  const _CreateCollectionDialog({required this.ref, required this.onCreated});

  @override
  State<_CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<_CreateCollectionDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _isCreating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _isCreating = true;
      _error = null;
    });
    try {
      await widget.ref.read(bookmarkActionsProvider).createCollection(name);
      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Collection'),
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
          onPressed: _isCreating ? null : _submit,
          child: _isCreating
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }
}
