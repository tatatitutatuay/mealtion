import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import 'package:mealtion/core/utils/price_level.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/meal_detail_provider.dart';
import '../providers/home_provider.dart';
import '../providers/gallery_provider.dart';
import '../../add_meal/providers/meal_api_provider.dart';
import '../../add_meal/screens/add_meal_sheet.dart';
import '../../bookmarks/providers/bookmark_provider.dart';
import '../../friends/providers/profile_provider.dart';

/// Meal detail bottom sheet.
/// [mealIds] supports vertical swipe between meals (calendar mode).
/// If single meal, pass [mealIds] with one element.
class MealDetailSheet extends ConsumerStatefulWidget {
  final List<String> mealIds;
  final int initialIndex;
  final bool canEdit;

  const MealDetailSheet({
    super.key,
    required this.mealIds,
    this.initialIndex = 0,
    this.canEdit = true,
  });

  /// Show for a single meal
  static void show(BuildContext context, String mealId, {bool canEdit = true}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MealDetailSheet(mealIds: [mealId], canEdit: canEdit),
    );
  }

  /// Show for multiple meals (calendar vertical swipe)
  static void showMultiple(BuildContext context, List<String> mealIds, {int initialIndex = 0, bool canEdit = true}) {
    if (mealIds.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MealDetailSheet(mealIds: mealIds, initialIndex: initialIndex, canEdit: canEdit),
    );
  }

  /// Show just the collection selector for a meal (bookmark action)
  static Future<void> showCollectionSelector(BuildContext context, WidgetRef ref, String mealId) async {
    final selected = await showModalBottomSheet<({String collectionId, bool alreadySaved})>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CollectionSelectorSheet(mealId: mealId),
    );

    if (selected == null || !context.mounted) return;

    final actions = ref.read(bookmarkActionsProvider);
    try {
      if (selected.alreadySaved) {
        await actions.removeMealFromCollection(selected.collectionId, mealId);
      } else {
        await actions.addMealToCollection(selected.collectionId, mealId);
      }
      ref.invalidate(mealCollectionIdsProvider(mealId));
      ref.invalidate(collectionMealsProvider(selected.collectionId));
      ref.invalidate(bookmarkCollectionsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(selected.alreadySaved ? 'Removed from collection' : 'Added to collection')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  ConsumerState<MealDetailSheet> createState() => _MealDetailSheetState();
}

class _MealDetailSheetState extends ConsumerState<MealDetailSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return _MealDetailBody(
          mealIds: widget.mealIds,
          initialIndex: widget.initialIndex,
          canEdit: widget.canEdit,
          scrollController: scrollController,
          onShowCollectionSelector: _showCollectionSelector,
          onConfirmDelete: _confirmDelete,
          onEdit: (mealId) {
            Navigator.pop(context);
            AddMealSheet.show(context, mealId: mealId);
          },
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  void _showCollectionSelector(String mealId) async {
    final selected = await showModalBottomSheet<({String collectionId, bool alreadySaved})>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CollectionSelectorSheet(
        mealId: mealId,
      ),
    );

    if (selected == null || !mounted) return;

    final actions = ref.read(bookmarkActionsProvider);
    try {
      if (selected.alreadySaved) {
        await actions.removeMealFromCollection(selected.collectionId, mealId);
      } else {
        await actions.addMealToCollection(selected.collectionId, mealId);
      }
      ref.invalidate(mealCollectionIdsProvider(mealId));
      ref.invalidate(collectionMealsProvider(selected.collectionId));
      ref.invalidate(bookmarkCollectionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(selected.alreadySaved ? 'Removed from collection' : 'Added to collection')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  void _confirmDelete(String mealId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete meal?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(mealApiProvider).deleteMeal(mealId);
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(galleryProvider);
      ref.invalidate(basePlaceBookmarksProvider);
      ref.invalidate(baseFoodBookmarksProvider);
      ref.invalidate(myProfileProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

}

/// Contains the header + meal PageView. Extracted into its own StatefulWidget
/// so it survives DraggableScrollableSheet builder rebuilds without resetting
/// the spinner animation.
class _MealDetailBody extends ConsumerStatefulWidget {
  final List<String> mealIds;
  final int initialIndex;
  final bool canEdit;
  final ScrollController scrollController;
  final void Function(String mealId) onShowCollectionSelector;
  final void Function(String mealId) onConfirmDelete;
  final void Function(String mealId) onEdit;
  final VoidCallback onClose;

  const _MealDetailBody({
    required this.mealIds,
    required this.initialIndex,
    required this.canEdit,
    required this.scrollController,
    required this.onShowCollectionSelector,
    required this.onConfirmDelete,
    required this.onEdit,
    required this.onClose,
  });

  @override
  ConsumerState<_MealDetailBody> createState() => _MealDetailBodyState();
}

class _MealDetailBodyState extends ConsumerState<_MealDetailBody> {
  late PageController _verticalController;
  late int _currentIndex;
  late PageController _photoController;
  int _currentPhotoPage = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _verticalController = PageController(initialPage: widget.initialIndex);
    _photoController = PageController();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  void _onMealChanged(int i) {
    final old = _photoController;
    setState(() {
      _currentIndex = i;
      _currentPhotoPage = 0;
      _photoController = PageController();
    });
    old.dispose();
    if (i + 1 < widget.mealIds.length) {
      ref.read(mealDetailProvider(widget.mealIds[i + 1]).future);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.mealIds.length > 1;

    return Column(
      children: [
        _header(),
        const Divider(height: 1),
        Expanded(
          child: hasMultiple
              ? PageView.builder(
                  controller: _verticalController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.mealIds.length,
                  onPageChanged: _onMealChanged,
                  itemBuilder: (_, i) => _MealContent(
                    key: ValueKey(widget.mealIds[i]),
                    mealId: widget.mealIds[i],
                    scrollController: i == _currentIndex ? widget.scrollController : null,
                    photoController: i == _currentIndex ? _photoController : null,
                    currentPhotoPage: i == _currentIndex ? _currentPhotoPage : 0,
                    onPhotoPageChanged: i == _currentIndex
                        ? (p) => setState(() => _currentPhotoPage = p)
                        : null,
                  ),
                )
              : _MealContent(
                  key: ValueKey(widget.mealIds.first),
                  mealId: widget.mealIds.first,
                  scrollController: widget.scrollController,
                  photoController: _photoController,
                  currentPhotoPage: _currentPhotoPage,
                  onPhotoPageChanged: (p) => setState(() => _currentPhotoPage = p),
                ),
        ),
      ],
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
          if (widget.mealIds.length > 1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, size: 16, color: _currentIndex > 0 ? AppColors.textPrimary : AppColors.grey500),
                Text('${_currentIndex + 1} / ${widget.mealIds.length}', style: AppTypography.s2),
                Icon(Icons.chevron_right, size: 16, color: _currentIndex < widget.mealIds.length - 1 ? AppColors.textPrimary : AppColors.grey500),
              ],
            ),
          if (widget.canEdit)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  onPressed: () => widget.onShowCollectionSelector(widget.mealIds[_currentIndex]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => widget.onConfirmDelete(widget.mealIds[_currentIndex]),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => widget.onEdit(widget.mealIds[_currentIndex]),
                ),
              ],
            ),
          if (!widget.canEdit)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: () => widget.onShowCollectionSelector(widget.mealIds[_currentIndex]),
            ),
        ],
      ),
    );
  }
}

/// Extracted widget so the spinner doesn't restart on parent rebuilds
class _MealContent extends ConsumerWidget {
  final String mealId;
  final ScrollController? scrollController;
  final PageController? photoController;
  final int currentPhotoPage;
  final ValueChanged<int>? onPhotoPageChanged;

  const _MealContent({
    super.key,
    required this.mealId,
    this.scrollController,
    this.photoController,
    this.currentPhotoPage = 0,
    this.onPhotoPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(mealDetailProvider(mealId));

    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (meal) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 250),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, opacity, _) => Opacity(
          opacity: opacity,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.layoutMargin),
            children: [
              _photoCarousel(meal.photoUrls),
              const SizedBox(height: 16),
              _dateTimeRow(meal),
              const SizedBox(height: 8),
              _foodsRow(meal.foods),
              if (meal.restaurantName != null) ...[
                const SizedBox(height: 8),
                _infoRow(Icons.place_outlined, [
                  if (meal.restaurantName != null) meal.restaurantName!,
                  if (meal.branchName != null) meal.branchName!,
                ].join(' · ')),
              ],
              if (meal.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                _tagsRow(meal.tags),
              ],
              if (meal.price != null) ...[
                const SizedBox(height: 8),
                _priceRow(meal.price!, ref),
              ],
              const SizedBox(height: 8),
              _chipsRow(meal.heaviness, meal.feeling),
              if (meal.note != null && meal.note!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _noteSection(meal.note!),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoCarousel(List<String> urls) {
    if (urls.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        ),
        child: const Center(child: Icon(Icons.photo_outlined, size: 48, color: AppColors.grey500)),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          child: SizedBox(
            height: 300,
            child: PageView.builder(
              controller: photoController,
              itemCount: urls.length,
              onPageChanged: onPhotoPageChanged,
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: urls[i],
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.grey100,
                  child: const Icon(Icons.broken_image_outlined, size: 48, color: AppColors.grey500),
                ),
              ),
            ),
          ),
        ),
        if (urls.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (i) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == currentPhotoPage ? AppColors.white : AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _dateTimeRow(MealDetail meal) {
    return Row(
      children: [
        Text(DateFormat('d MMM yyyy').format(meal.date), style: AppTypography.b2),
        if (meal.time != null) ...[
          const SizedBox(width: 8),
          Text('· ${meal.time!.substring(0, 5)}', style: AppTypography.b2.copyWith(color: AppColors.textSecondary)),
        ],
        const Spacer(),
        if (meal.isPrivate)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
            ),
            child: Text('Private', style: AppTypography.c2.copyWith(color: AppColors.textSecondary)),
          ),
      ],
    );
  }

  Widget _foodsRow(List<String> foods) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: foods
          .map((f) => Chip(
                label: Text(f, style: AppTypography.b3),
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: AppTypography.b3.copyWith(color: AppColors.textSecondary))),
      ],
    );
  }

  Widget _tagsRow(List<String> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags
          .map((t) => Text(
                '#$t',
                style: AppTypography.b3.copyWith(color: AppColors.primary),
              ))
          .toList(),
    );
  }

  Widget _priceRow(double price, WidgetRef ref) {
    final auth = ref.read(authProvider);
    final privacy = auth?.priceDisplayPrivacy ?? 'actual';
    if (privacy == 'hidden') return const SizedBox.shrink();

    final level = calculatePriceLevel(
      price,
      auth?.priceThresholdLow ?? 10.0,
      auth?.priceThresholdHigh ?? 50.0,
    );
    return Row(
      children: [
        if (privacy == 'actual')
          Text('\$${price.toStringAsFixed(2)}', style: AppTypography.s2),
        if (privacy == 'actual') const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: level.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(level.icon, size: 12, color: level.color),
              const SizedBox(width: 4),
              Text(level.label, style: AppTypography.b5.copyWith(color: level.color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chipsRow(String? heaviness, String? feeling) {
    return Row(
      children: [
        if (heaviness != null) _chip(heaviness, _heavinessColor(heaviness)),
        if (heaviness != null && feeling != null) const SizedBox(width: 8),
        if (feeling != null) _chip(feeling, _feelingColor(feeling)),
      ],
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
      ),
      child: Text(_capitalize(label), style: AppTypography.c2.copyWith(color: color)),
    );
  }

  Widget _noteSection(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(note, style: AppTypography.b3),
    );
  }

  Color _heavinessColor(String h) => switch (h) {
        'light' => AppColors.heavinessLight,
        'satisfying' => AppColors.heavinessSatisfying,
        'heavy' => AppColors.heavinessHeavy,
        _ => AppColors.grey500,
      };

  Color _feelingColor(String f) => switch (f) {
        'like' => AppColors.feelingLike,
        'neutral' => AppColors.feelingNeutral,
        'dislike' => AppColors.feelingDislike,
        _ => AppColors.grey500,
      };

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _CollectionSelectorSheet extends ConsumerWidget {
  final String mealId;

  const _CollectionSelectorSheet({
    required this.mealId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(bookmarkCollectionsProvider);
    final existingIdsAsync = ref.watch(mealCollectionIdsProvider(mealId));

    final collections = collectionsAsync.valueOrNull ?? <BookmarkCollection>[];
    final existingIds = existingIdsAsync.valueOrNull ?? <String>{};
    final isLoading = collectionsAsync.isLoading && collections.isEmpty;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Save to collection', style: AppTypography.s2),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add, color: AppColors.primary),
            title: Text('New Collection', style: AppTypography.b3.copyWith(color: AppColors.primary)),
            onTap: () async {
              final id = await showDialog<String>(
                context: context,
                builder: (dctx) => _CreateCollectionDialog(
                  onCreate: (name) async {
                    return await ref.read(bookmarkActionsProvider).createCollection(name);
                  },
                ),
              );
              if (id != null && context.mounted) {
                Navigator.pop(context, (collectionId: id, alreadySaved: false));
              }
            },
          ),
          const Divider(height: 1),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            ...collections.map((c) {
              final alreadySaved = existingIds.contains(c.id);
              return ListTile(
                leading: Icon(alreadySaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: alreadySaved ? AppColors.primary : null),
                title: Text(c.name),
                subtitle: Text('${c.itemCount} items'),
                trailing: alreadySaved ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () => Navigator.pop(context, (collectionId: c.id, alreadySaved: alreadySaved)),
              );
            }),
            if (collections.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No collections yet. Create one!', style: AppTypography.b4),
              ),
          ],
        ],
      ),
    );
  }
}

class _CreateCollectionDialog extends StatefulWidget {
  final Future<String> Function(String name) onCreate;

  const _CreateCollectionDialog({required this.onCreate});

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
      final id = await widget.onCreate(name);
      if (mounted) Navigator.pop(context, id);
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
