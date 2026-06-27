import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import 'package:path_provider/path_provider.dart';
import '../models/add_meal_state.dart';
import '../providers/add_meal_provider.dart';
import '../providers/draft_provider.dart';
import '../providers/meal_api_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../home/providers/gallery_provider.dart';
import '../../home/providers/meal_detail_provider.dart';
import '../../bookmarks/providers/bookmark_provider.dart';
import '../../friends/providers/profile_provider.dart';
import '../../friends/providers/friends_providers.dart';
import '../widgets/photo_picker.dart';
import '../widgets/food_chips.dart';
import '../widgets/source_selector.dart';
import '../widgets/price_input.dart';
import '../widgets/heaviness_feeling_selector.dart';
import '../widgets/restaurant_search.dart';
import '../widgets/tag_input.dart';

class AddMealSheet extends ConsumerStatefulWidget {
  final String? mealId;

  const AddMealSheet({super.key, this.mealId});

  static void show(BuildContext context, {String? mealId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddMealSheet(mealId: mealId),
    );
  }

  @override
  ConsumerState<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<AddMealSheet> {
  late TextEditingController _noteController;
  final _picker = ImagePicker();
  bool _isSaving = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    if (widget.mealId != null) {
      _loadMealForEdit();
    }
  }

  Future<void> _loadMealForEdit() async {
    setState(() => _isLoading = true);
    try {
      final meal = await ref.read(mealDetailProvider(widget.mealId!).future);
      final notifier = ref.read(addMealProvider.notifier);
      notifier.reset();

      // Download photos to temp files
      final photos = <AddMealPhoto>[];
      for (var i = 0; i < meal.photoUrls.length; i++) {
        final url = meal.photoUrls[i];
        try {
          final response = await http.get(Uri.parse(url));
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/edit_${widget.mealId}_$i.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          photos.add(AddMealPhoto(localPath: filePath, file: file, sortOrder: i, isExisting: true, storagePath: url));
        } catch (e) {
          debugPrint('Failed to download photo $i: $e');
        }
      }

      notifier.setPhotos(photos);
      notifier.setDate(meal.date);
      if (meal.time != null) {
        final parts = meal.time!.split(':');
        notifier.setTime(TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])));
      }
      notifier.setSource(MealSource.values.firstWhere(
        (s) => s.name == meal.source,
        orElse: () => MealSource.restaurant,
      ));
      for (final food in meal.foods) {
        notifier.addFood(food);
      }
      for (final tag in meal.tags) {
        notifier.addTag(tag);
      }
      if (meal.restaurantName != null) notifier.setRestaurant(meal.restaurantName);
      if (meal.branchName != null) notifier.setBranch(meal.branchName);
      if (meal.price != null) notifier.setPrice(meal.price);
      if (meal.heaviness != null) {
        notifier.setHeaviness(Heaviness.values.firstWhere(
          (h) => h.name == meal.heaviness,
          orElse: () => Heaviness.light,
        ));
      }
      if (meal.feeling != null) {
        notifier.setFeeling(Feeling.values.firstWhere(
          (f) => f.name == meal.feeling,
          orElse: () => Feeling.like,
        ));
      }
      notifier.setNote(meal.note);
      _noteController.text = meal.note ?? '';
      notifier.setPrivate(meal.isPrivate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load meal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final files = await _picker.pickMultiImage();
    if (files.isEmpty) return;

    final state = ref.read(addMealProvider);
    final currentCount = state.photos.length;
    final remaining = 10 - currentCount;

    final photos = <AddMealPhoto>[];
    for (var i = 0; i < files.length && i < remaining; i++) {
      photos.add(AddMealPhoto(
        localPath: files[i].path,
        file: File(files[i].path),
        sortOrder: currentCount + i,
      ));
    }

    ref.read(addMealProvider.notifier).setPhotos([...state.photos, ...photos]);
  }

  Future<void> _pickCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    final state = ref.read(addMealProvider);
    if (state.photos.length >= 10) return;

    ref.read(addMealProvider.notifier).setPhotos([
      ...state.photos,
      AddMealPhoto(localPath: file.path, file: File(file.path), sortOrder: state.photos.length),
    ]);
  }

  Future<void> _showDrafts() async {
    await ref.read(draftProvider.notifier).load();
    if (!mounted) return;
    final drafts = ref.read(draftProvider);
    if (drafts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No drafts saved')),
      );
      return;
    }
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Drafts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const Divider(height: 1),
            ...drafts.map((d) => ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: Text(d.state.foods.isNotEmpty ? d.state.foods.map((f) => f.name).join(', ') : 'Untitled'),
                  subtitle: Text('${d.state.date.day}/${d.state.date.month}/${d.state.date.year}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () {
                      ref.read(draftProvider.notifier).delete(d.id);
                      Navigator.pop(ctx, '__deleted__');
                    },
                  ),
                  onTap: () => Navigator.pop(ctx, d.id),
                )),
          ],
        ),
      ),
    );
    if (selectedId == null || selectedId == '__deleted__') return;
    final draft = drafts.firstWhere((d) => d.id == selectedId);
    final notifier = ref.read(addMealProvider.notifier);
    notifier.setPhotos(const []);
    notifier.setDate(draft.state.date);
    notifier.setTime(draft.state.time);
    notifier.setSource(draft.state.source);
    for (final food in draft.state.foods) {
      notifier.addFood(food.name);
    }
    for (final tag in draft.state.tags) {
      notifier.addTag(tag);
    }
    notifier.setRestaurant(draft.state.restaurant);
    notifier.setBranch(draft.state.branch);
    notifier.setPrice(draft.state.price);
    notifier.setHeaviness(draft.state.heaviness);
    notifier.setFeeling(draft.state.feeling);
    notifier.setNote(draft.state.note);
    _noteController.text = draft.state.note ?? '';
    notifier.setPrivate(draft.state.isPrivate);
    ref.read(draftProvider.notifier).delete(draft.id);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final state = ref.read(addMealProvider);
    if (!state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 photo and 1 food name')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final api = ref.read(mealApiProvider);
      if (widget.mealId != null) {
        await api.updateMeal(widget.mealId!, state);
        ref.invalidate(mealDetailProvider(widget.mealId!));
      } else {
        await api.createMeal(state);
      }
      ref.read(addMealProvider.notifier).reset();
      // Refresh all screens that show meal data
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(galleryProvider);
      ref.invalidate(friendsFeedProvider);
      ref.invalidate(basePlaceBookmarksProvider);
      ref.invalidate(baseFoodBookmarksProvider);
      ref.invalidate(myProfileProvider);
      if (mounted) Navigator.pop(context, widget.mealId ?? true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.mealId != null ? 'Meal updated!' : 'Meal saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(addMealProvider);
    if (!state.hasData) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Do you want to leave this meal?'),
        content: const Text('Unsaved information will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'draft'),
            child: const Text('Save as Draft'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result == 'discard') {
      ref.read(addMealProvider.notifier).reset();
      return true;
    }
    if (result == 'draft') {
      await ref.read(draftProvider.notifier).save(state);
      ref.read(addMealProvider.notifier).reset();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addMealProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          if (_isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return Scaffold(
            body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (await _onWillPop() && context.mounted) Navigator.pop(context);
                      },
                      child: const Icon(Icons.close, size: 24, color: AppColors.textPrimary),
                    ),
                    Text(
                      widget.mealId != null ? 'Edit Meal' : 'Add Meal',
                      style: AppTypography.s1.copyWith(
                          color: AppColors.textPrimary, fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: () => _showDrafts(),
                      child: const Icon(Icons.edit_note, size: 24, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5, color: AppColors.border),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.layoutMargin, vertical: 16),
                  children: [
                    PhotoPicker(
                      photos: state.photos,
                      onPickGallery: _pickPhotos,
                      onPickCamera: _pickCamera,
                      onRemove: (i) => ref.read(addMealProvider.notifier).removePhoto(i),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Date & Time'),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: state.date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) ref.read(addMealProvider.notifier).setDate(date);
                            },
                            child: Container(
                              height: 28,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: AppSpacing.cardBorder,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: AppColors.textPrimary),
                                  const SizedBox(width: 6),
                                  Text(DateFormat('d MMM yyyy').format(state.date),
                                      style: AppTypography.b5.copyWith(
                                          color: AppColors.textPrimary, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: state.time,
                              );
                              if (time != null) ref.read(addMealProvider.notifier).setTime(time);
                            },
                            child: Container(
                              height: 28,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: AppSpacing.cardBorder,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.access_time, size: 12, color: AppColors.textPrimary),
                                  const SizedBox(width: 6),
                                  Text(state.time.format(context),
                                      style: AppTypography.b5.copyWith(
                                          color: AppColors.textPrimary, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Meal Names'),
                    FoodChips(
                      foods: state.foods,
                      onAdd: (name) => ref.read(addMealProvider.notifier).addFood(name),
                      onRemove: (i) => ref.read(addMealProvider.notifier).removeFood(i),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Source'),
                    SourceSelector(
                      source: state.source,
                      onChanged: (s) => ref.read(addMealProvider.notifier).setSource(s),
                    ),
                    if (state.source != MealSource.home) ...[
                      const SizedBox(height: 12),
                      RestaurantSearch(
                        restaurant: state.restaurant,
                        branch: state.branch,
                        onRestaurantChanged: (r) => ref.read(addMealProvider.notifier).setRestaurant(r),
                        onBranchChanged: (b) => ref.read(addMealProvider.notifier).setBranch(b),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildSectionTitle('Tags'),
                    TagInput(
                      tags: state.tags,
                      onAdd: (t) => ref.read(addMealProvider.notifier).addTag(t),
                      onRemove: (t) => ref.read(addMealProvider.notifier).removeTag(t),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Price'),
                    PriceInput(
                      price: state.price,
                      onChanged: (p) => ref.read(addMealProvider.notifier).setPrice(p),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Heaviness & Feeling'),
                    HeavinessFeelingSelector(
                      heaviness: state.heaviness,
                      feeling: state.feeling,
                      onHeavinessChanged: (h) => ref.read(addMealProvider.notifier).setHeaviness(h),
                      onFeelingChanged: (f) => ref.read(addMealProvider.notifier).setFeeling(f),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Note'),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        hintStyle: AppTypography.b5.copyWith(color: AppColors.textFaded),
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
                      ),
                      style: AppTypography.b5.copyWith(color: AppColors.textPrimary),
                      onChanged: (v) => ref.read(addMealProvider.notifier).setNote(v),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => ref.read(addMealProvider.notifier).setPrivate(!state.isPrivate),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: AppSpacing.cardBorder,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                        ),
                        child: Row(
                          children: [
                            Icon(state.isPrivate ? Icons.lock : Icons.lock_open,
                                size: 16, color: AppColors.textPrimary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Private Meal',
                                      style: AppTypography.b5.copyWith(
                                          color: AppColors.textPrimary, fontSize: 12)),
                                  Text('Only you can see this meal',
                                      style: AppTypography.b5.copyWith(
                                          color: AppColors.textFaded, fontSize: 12)),
                                ],
                              ),
                            ),
                            Switch(
                              value: state.isPrivate,
                              onChanged: (v) => ref.read(addMealProvider.notifier).setPrivate(v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _isSaving ? null : _save,
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: AppSpacing.cardBorder,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        alignment: Alignment.center,
                        child: _isSaving
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
                            : Text(_isSaving ? 'Saving...' : 'Save Meal',
                                style: AppTypography.buttonMedium.copyWith(color: AppColors.textPrimary)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTypography.s2.copyWith(
          color: AppColors.textPrimary, fontSize: 16)),
    );
  }
}
