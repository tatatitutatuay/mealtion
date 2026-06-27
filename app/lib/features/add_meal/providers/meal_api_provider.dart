import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/add_meal_state.dart';

final mealApiProvider = Provider<MealApi>((ref) {
  return MealApi(ref.watch(supabaseProvider));
});

class MealApi {
  final SupabaseClient _supabase;

  MealApi(this._supabase);

  Future<void> createMeal(AddMealState state) async {
    final userId = _supabase.auth.currentUser!.id;

    String? restaurantId;
    String? branchId;
    if (state.restaurant != null && state.source != MealSource.home) {
      final existing = await _supabase
          .from('restaurants')
          .select('id')
          .eq('user_id', userId)
          .eq('name', state.restaurant!)
          .maybeSingle();

      if (existing != null) {
        restaurantId = existing['id'] as String;
      } else {
        final result = await _supabase
            .from('restaurants')
            .insert({'user_id': userId, 'name': state.restaurant!})
            .select('id')
            .single();
        restaurantId = result['id'] as String;
      }

      if (state.branch != null) {
        final existingBranch = await _supabase
            .from('branches')
            .select('id')
            .eq('restaurant_id', restaurantId)
            .eq('user_id', userId)
            .eq('name', state.branch!)
            .maybeSingle();

        if (existingBranch != null) {
          branchId = existingBranch['id'] as String;
        } else {
          final result = await _supabase
              .from('branches')
              .insert({'restaurant_id': restaurantId, 'user_id': userId, 'name': state.branch!})
              .select('id')
              .single();
          branchId = result['id'] as String;
        }
      }
    }

    final mealResult = await _supabase.from('meals').insert({
      'user_id': userId,
      'date': state.date.toIso8601String().split('T')[0],
      'time': '${state.time.hour.toString().padLeft(2, '0')}:${state.time.minute.toString().padLeft(2, '0')}:00',
      'source': state.source.name,
      'restaurant_id': restaurantId,
      'branch_id': branchId,
      'is_private': state.isPrivate,
      'price_amount': state.price,
      'heaviness': state.heaviness?.name,
      'feeling': state.feeling?.name,
      'note': state.note,
    }).select('id').single();

    final mealId = mealResult['id'] as String;

    for (var i = 0; i < state.photos.length; i++) {
      final photo = state.photos[i];
      final ext = photo.file.path.split('.').last;
      final storagePath = '$userId/$mealId/$i.$ext';
      await _supabase.storage.from('meal-photos').upload(storagePath, photo.file);
      final publicUrl = _supabase.storage.from('meal-photos').getPublicUrl(storagePath);
      await _supabase.from('meal_photos').insert({
        'meal_id': mealId,
        'storage_path': publicUrl,
        'sort_order': i,
      });
    }

    for (var i = 0; i < state.foods.length; i++) {
      await _supabase.from('meal_foods').insert({
        'meal_id': mealId,
        'food_name': state.foods[i].name,
        'sort_order': i,
      });
    }

    for (final tag in state.tags) {
      await _supabase.from('meal_tags').insert({
        'meal_id': mealId,
        'tag_name': tag,
      });
    }
  }

  Future<void> updateMeal(String mealId, AddMealState state) async {
    final userId = _supabase.auth.currentUser!.id;

    String? restaurantId;
    String? branchId;
    if (state.restaurant != null && state.source != MealSource.home) {
      final existing = await _supabase
          .from('restaurants')
          .select('id')
          .eq('user_id', userId)
          .eq('name', state.restaurant!)
          .maybeSingle();

      if (existing != null) {
        restaurantId = existing['id'] as String;
      } else {
        final result = await _supabase
            .from('restaurants')
            .insert({'user_id': userId, 'name': state.restaurant!})
            .select('id')
            .single();
        restaurantId = result['id'] as String;
      }

      if (state.branch != null) {
        final existingBranch = await _supabase
            .from('branches')
            .select('id')
            .eq('restaurant_id', restaurantId)
            .eq('user_id', userId)
            .eq('name', state.branch!)
            .maybeSingle();

        if (existingBranch != null) {
          branchId = existingBranch['id'] as String;
        } else {
          final result = await _supabase
              .from('branches')
              .insert({'restaurant_id': restaurantId, 'user_id': userId, 'name': state.branch!})
              .select('id')
              .single();
          branchId = result['id'] as String;
        }
      }
    }

    await _supabase.from('meals').update({
      'date': state.date.toIso8601String().split('T')[0],
      'time': '${state.time.hour.toString().padLeft(2, '0')}:${state.time.minute.toString().padLeft(2, '0')}:00',
      'source': state.source.name,
      'restaurant_id': restaurantId,
      'branch_id': branchId,
      'is_private': state.isPrivate,
      'price_amount': state.price,
      'heaviness': state.heaviness?.name,
      'feeling': state.feeling?.name,
      'note': state.note,
    }).eq('id', mealId);

    // Photos: delete removed, upload new, update sort_order for all
    final dbPhotos = await _supabase
        .from('meal_photos')
        .select('id, storage_path')
        .eq('meal_id', mealId);
    final dbPhotoIds = <String, String>{}; // storage_path -> id
    for (final p in (dbPhotos as List<dynamic>)) {
      final row = p as Map<String, dynamic>;
      dbPhotoIds[row['storage_path'] as String] = row['id'] as String;
    }

    // Determine which existing photos are kept (by storage_path)
    final keptPaths = state.photos
        .where((p) => p.isExisting && p.storagePath != null)
        .map((p) => p.storagePath!)
        .toSet();

    // Delete removed photos from DB + storage
    final removedPaths = dbPhotoIds.keys.toSet().difference(keptPaths);
    for (final path in removedPaths) {
      await _supabase.from('meal_photos').delete().eq('id', dbPhotoIds[path]!);
      _deletePhotoFromStorage(path);
    }

    // Upload new photos and update sort_order for all
    for (var i = 0; i < state.photos.length; i++) {
      final photo = state.photos[i];
      if (!photo.isExisting) {
        final ext = photo.file.path.split('.').last;
        final storagePath = '$userId/$mealId/$i.$ext';
        await _supabase.storage.from('meal-photos').upload(storagePath, photo.file);
        final publicUrl = _supabase.storage.from('meal-photos').getPublicUrl(storagePath);
        await _supabase.from('meal_photos').insert({
          'meal_id': mealId,
          'storage_path': publicUrl,
          'sort_order': i,
        });
      } else if (photo.storagePath != null && dbPhotoIds.containsKey(photo.storagePath)) {
        await _supabase.from('meal_photos')
            .update({'sort_order': i})
            .eq('id', dbPhotoIds[photo.storagePath]!);
      }
    }

    // Replace foods: insert new, delete removed
    for (var i = 0; i < state.foods.length; i++) {
      try {
        await _supabase.from('meal_foods').insert({
          'meal_id': mealId,
          'food_name': state.foods[i].name,
          'sort_order': i,
        });
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          await _supabase.from('meal_foods')
              .update({'sort_order': i})
              .eq('meal_id', mealId)
              .eq('food_name', state.foods[i].name);
        } else {
          rethrow;
        }
      }
    }
    final existingFoods = await _supabase
        .from('meal_foods')
        .select('food_name')
        .eq('meal_id', mealId);
    final dbFoods = (existingFoods as List<dynamic>)
        .map((f) => (f as Map<String, dynamic>)['food_name'] as String)
        .toSet();
    final removedFoods = dbFoods.difference(state.foods.map((f) => f.name).toSet());
    for (final food in removedFoods) {
      await _supabase.from('meal_foods')
          .delete()
          .eq('meal_id', mealId)
          .eq('food_name', food);
    }

    // Replace tags: insert new, delete removed
    for (final tag in state.tags) {
      try {
        await _supabase.from('meal_tags').insert({
          'meal_id': mealId,
          'tag_name': tag,
        });
      } on PostgrestException catch (e) {
        if (e.code != '23505') rethrow;
      }
    }
    final existingTags = await _supabase
        .from('meal_tags')
        .select('tag_name')
        .eq('meal_id', mealId);
    final dbTags = (existingTags as List<dynamic>)
        .map((t) => (t as Map<String, dynamic>)['tag_name'] as String)
        .toSet();
    final removedTags = dbTags.difference(state.tags.toSet());
    for (final tag in removedTags) {
      await _supabase.from('meal_tags')
          .delete()
          .eq('meal_id', mealId)
          .eq('tag_name', tag);
    }
  }

  Future<void> deleteMeal(String mealId) async {
    final userId = _supabase.auth.currentUser!.id;
    // Delete photos from storage
    final photos = await _supabase
        .from('meal_photos')
        .select('storage_path')
        .eq('meal_id', mealId);
    for (final p in (photos as List<dynamic>)) {
      final url = p['storage_path'] as String;
      _deletePhotoFromStorage(url);
    }
    // Delete meal row (cascades to meal_photos, meal_foods, meal_tags)
    await _supabase.from('meals').delete().eq('id', mealId).eq('user_id', userId);
  }

  void _deletePhotoFromStorage(String storagePathOrUrl) {
    String? rawPath;
    if (storagePathOrUrl.startsWith('http')) {
      final uri = Uri.parse(storagePathOrUrl);
      final pathSegments = uri.pathSegments;
      final bucketIdx = pathSegments.indexOf('meal-photos');
      if (bucketIdx >= 0 && bucketIdx + 1 < pathSegments.length) {
        rawPath = pathSegments.sublist(bucketIdx + 1).join('/');
      }
    } else {
      rawPath = storagePathOrUrl;
    }
    if (rawPath != null) {
      try {
        _supabase.storage.from('meal-photos').remove([rawPath]);
      } catch (_) {}
    }
  }
}
