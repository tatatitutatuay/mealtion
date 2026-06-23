import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import '../models/add_meal_state.dart';
import '../providers/add_meal_provider.dart';
import '../providers/meal_api_provider.dart';
import '../widgets/photo_picker.dart';
import '../widgets/food_chips.dart';
import '../widgets/source_selector.dart';
import '../widgets/price_input.dart';
import '../widgets/heaviness_feeling_selector.dart';
import '../widgets/restaurant_search.dart';
import '../widgets/tag_input.dart';

class AddMealSheet extends ConsumerStatefulWidget {
  const AddMealSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddMealSheet(),
    );
  }

  @override
  ConsumerState<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<AddMealSheet> {
  late TextEditingController _noteController;
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
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

  Future<void> _save() async {
    final state = ref.read(addMealProvider);
    if (!state.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 photo and 1 food name')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(mealApiProvider).createMeal(state);
      ref.read(addMealProvider.notifier).reset();
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal saved!')),
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
      // TODO: save as draft to Isar
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
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        if (await _onWillPop() && context.mounted) Navigator.pop(context);
                      },
                    ),
                    const Text('Add Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      onPressed: () {
                        // TODO: open drafts
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
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
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(DateFormat('d MMM yyyy').format(state.date)),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: state.date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) ref.read(addMealProvider.notifier).setDate(date);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(state.time.format(context)),
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: state.time,
                              );
                              if (time != null) ref.read(addMealProvider.notifier).setTime(time);
                            },
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
                      decoration: const InputDecoration(
                        hintText: 'Add a note...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => ref.read(addMealProvider.notifier).setNote(v),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Private Meal'),
                      subtitle: const Text('Only you can see this meal'),
                      value: state.isPrivate,
                      onChanged: (v) => ref.read(addMealProvider.notifier).setPrivate(v),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Meal'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
    );
  }
}
