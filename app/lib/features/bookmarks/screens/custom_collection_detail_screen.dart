import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/bookmark_provider.dart';
import '../../home/widgets/meal_detail_sheet.dart';

class CustomCollectionDetailScreen extends ConsumerWidget {
  final String collectionId;
  final String collectionName;

  const CustomCollectionDetailScreen({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(collectionMealsProvider(collectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showMenu(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 12),
              child: Row(
                children: [
                  Text(collectionName, style: AppTypography.s2),
                  const SizedBox(width: 8),
                  meals.maybeWhen(
                    data: (list) => Text('${list.length} Collections',
                        style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: meals.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Text('No saved meals yet',
                          style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _gridTile(context, list[i], list.map((m) => m.mealId).toList(), i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridTile(BuildContext context, CollectionMeal meal, List<String> allMealIds, int index) {
    return GestureDetector(
      onTap: () => MealDetailSheet.showMultiple(context, allMealIds, initialIndex: index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(meal.thumbnailUrl, fit: BoxFit.cover),
            if (meal.photoCount > 1)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.collections, color: AppColors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename Collection'),
              onTap: () {
                Navigator.pop(ctx);
                _renameCollection(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Collection', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('Delete Collection'),
                    content: Text('Delete "$collectionName"? This won\'t delete the original meals.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(d, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    await ref.read(bookmarkActionsProvider).deleteCollection(collectionId);
                    ref.invalidate(bookmarkCollectionsProvider);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _renameCollection(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _RenameCollectionDialog(
        collectionId: collectionId,
        name: collectionName,
        ref: ref,
        onRenamed: () {
          ref.invalidate(bookmarkCollectionsProvider);
          ref.invalidate(collectionMealsProvider(collectionId));
        },
      ),
    );
  }
}

class _RenameCollectionDialog extends StatefulWidget {
  final String collectionId;
  final String name;
  final WidgetRef ref;
  final VoidCallback onRenamed;

  const _RenameCollectionDialog({
    required this.collectionId,
    required this.name,
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
    _controller = TextEditingController(text: widget.name);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newName = _controller.text.trim();
    if (newName.isEmpty || newName == widget.name) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.ref.read(bookmarkActionsProvider).renameCollection(widget.collectionId, newName);
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
