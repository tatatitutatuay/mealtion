import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      builder: (_) => MealDetailSheet(mealIds: mealIds, initialIndex: initialIndex, canEdit: canEdit),
    );
  }

  @override
  ConsumerState<MealDetailSheet> createState() => _MealDetailSheetState();
}

class _MealDetailSheetState extends ConsumerState<MealDetailSheet> {
  late PageController _verticalController;
  late int _currentIndex;
  late PageController _photoController;

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

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.mealIds.length > 1;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _header(),
            const Divider(height: 1),
            Expanded(
              child: hasMultiple
                  ? PageView.builder(
                      controller: _verticalController,
                      scrollDirection: Axis.vertical,
                      itemCount: widget.mealIds.length,
                      onPageChanged: (i) {
                        setState(() {
                          _currentIndex = i;
                          _photoController = PageController();
                        });
                      },
                      itemBuilder: (_, i) => _mealContent(widget.mealIds[i]),
                    )
                  : _mealContent(widget.mealIds.first),
            ),
          ],
        );
      },
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
            onPressed: () => Navigator.pop(context),
          ),
          if (widget.mealIds.length > 1)
            Text('${_currentIndex + 1} / ${widget.mealIds.length}', style: AppTypography.s2),
          if (widget.canEdit)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  onPressed: () => _showCollectionSelector(widget.mealIds[_currentIndex]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _confirmDelete(widget.mealIds[_currentIndex]),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                    AddMealSheet.show(context, mealId: widget.mealIds[_currentIndex]);
                  },
                ),
              ],
            ),
          if (!widget.canEdit)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: () => _showCollectionSelector(widget.mealIds[_currentIndex]),
            ),
        ],
      ),
    );
  }

  void _showCollectionSelector(String mealId) async {
    final selected = await showModalBottomSheet<({String collectionId, bool alreadySaved})>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CollectionSelectorSheet(
        mealId: mealId,
        onCreate: () async {
          final name = await showDialog<String>(
            context: ctx,
            builder: (dctx) => _CreateCollectionDialog(),
          );
          return name;
        },
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

  Widget _mealContent(String mealId) {
    final detail = ref.watch(mealDetailProvider(mealId));

    return detail.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (meal) => ListView(
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
            _priceRow(meal.price!),
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
              controller: _photoController,
              itemCount: urls.length,
              itemBuilder: (_, i) => Image.network(
                urls[i],
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, __, ___) => Container(
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
                    color: i == 0 ? AppColors.white : AppColors.white.withValues(alpha: 0.5),
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

  Widget _priceRow(double price) {
    final auth = ref.read(authProvider);
    final level = calculatePriceLevel(
      price,
      auth?.priceThresholdLow ?? 10.0,
      auth?.priceThresholdHigh ?? 50.0,
    );
    return Row(
      children: [
        Text('\$${price.toStringAsFixed(2)}', style: AppTypography.s2),
        const SizedBox(width: 8),
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
  final Future<String?> Function() onCreate;

  const _CollectionSelectorSheet({
    required this.mealId,
    required this.onCreate,
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
              final name = await onCreate();
              if (name == null || !context.mounted) return;
              try {
                final id = await ref.read(bookmarkActionsProvider).createCollection(name);
                if (context.mounted) Navigator.pop(context, (collectionId: id, alreadySaved: false));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
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
  @override
  State<_CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<_CreateCollectionDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Collection'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Collection name'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
