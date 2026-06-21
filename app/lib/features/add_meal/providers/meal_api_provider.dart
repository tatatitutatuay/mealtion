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
      await _supabase.from('meal_photos').insert({
        'meal_id': mealId,
        'storage_path': storagePath,
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
}
