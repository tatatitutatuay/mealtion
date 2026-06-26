import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';

class BookmarkCollection {
  final String id;
  final String name;
  final String? coverKey;
  final int itemCount;

  BookmarkCollection({
    required this.id,
    required this.name,
    this.coverKey,
    this.itemCount = 0,
  });
}

class BaseBookmarkItem {
  final String name;
  final String? subtitle;
  final String? thumbnailUrl;
  final int mealCount;

  BaseBookmarkItem({
    required this.name,
    this.subtitle,
    this.thumbnailUrl,
    this.mealCount = 0,
  });
}

final bookmarkCollectionsProvider = FutureProvider<List<BookmarkCollection>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);

  final rows = await supabase
      .from('bookmark_collections')
      .select('''
        id, name, cover_key,
        bookmark_items(id)
      ''')
      .eq('user_id', auth.id)
      .order('created_at', ascending: false);

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) {
        final items = (r['bookmark_items'] as List<dynamic>?) ?? [];
        return BookmarkCollection(
          id: r['id'] as String,
          name: r['name'] as String,
          coverKey: r['cover_key'] as String?,
          itemCount: items.length,
        );
      })
      .toList();
});

final basePlaceBookmarksProvider = FutureProvider<List<BaseBookmarkItem>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);

  final rows = await supabase
      .from('meals')
      .select('''
        restaurants(id, name),
        branches(id, name),
        meal_photos(id, storage_path, sort_order)
      ''')
      .eq('user_id', auth.id)
      .not('restaurant_id', 'is', null)
      .order('date', ascending: false);

  final grouped = <String, BaseBookmarkItem>{};
  for (final row in (rows as List<dynamic>).cast<Map<String, dynamic>>()) {
    final restaurant = row['restaurants'] as Map<String, dynamic>?;
    final branch = row['branches'] as Map<String, dynamic>?;
    if (restaurant == null) continue;

    final name = restaurant['name'] as String;
    final branchName = branch?['name'] as String?;
    final key = '$name|${branchName ?? ''}';

    final photos = (row['meal_photos'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        .where((p) => p['storage_path'] != null)
        .toList() ?? [];

    if (grouped.containsKey(key)) {
      final existing = grouped[key]!;
      grouped[key] = BaseBookmarkItem(
        name: existing.name,
        subtitle: existing.subtitle,
        thumbnailUrl: existing.thumbnailUrl ?? (photos.isNotEmpty ? resolvePhotoUrl(supabase, photos.first['storage_path'] as String) : null),
        mealCount: existing.mealCount + 1,
      );
    } else {
      grouped[key] = BaseBookmarkItem(
        name: name,
        subtitle: branchName,
        thumbnailUrl: photos.isNotEmpty ? resolvePhotoUrl(supabase, photos.first['storage_path'] as String) : null,
        mealCount: 1,
      );
    }
  }

  final items = grouped.values.toList();
  items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return items;
});

final baseFoodBookmarksProvider = FutureProvider<List<BaseBookmarkItem>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);

  final rows = await supabase
      .from('meal_foods')
      .select('''
        food_name,
        meals!inner(id, user_id, date, meal_photos(id, storage_path, sort_order))
      ''')
      .eq('meals.user_id', auth.id);

  final grouped = <String, BaseBookmarkItem>{};
  for (final row in (rows as List<dynamic>).cast<Map<String, dynamic>>()) {
    final name = row['food_name'] as String;
    final meal = row['meals'] as Map<String, dynamic>?;
    if (meal == null) continue;

    final photos = (meal['meal_photos'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        .where((p) => p['storage_path'] != null)
        .toList() ?? [];

    if (grouped.containsKey(name)) {
      final existing = grouped[name]!;
      grouped[name] = BaseBookmarkItem(
        name: existing.name,
        thumbnailUrl: existing.thumbnailUrl ?? (photos.isNotEmpty ? resolvePhotoUrl(supabase, photos.first['storage_path'] as String) : null),
        mealCount: existing.mealCount + 1,
      );
    } else {
      grouped[name] = BaseBookmarkItem(
        name: name,
        thumbnailUrl: photos.isNotEmpty ? resolvePhotoUrl(supabase, photos.first['storage_path'] as String) : null,
        mealCount: 1,
      );
    }
  }

  final items = grouped.values.toList();
  items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return items;
});

/// Set of collection IDs that already contain [mealId]
final mealCollectionIdsProvider = FutureProvider.family<Set<String>, String>((ref, mealId) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return {};
  final supabase = ref.watch(supabaseProvider);

  final rows = await supabase
      .from('bookmark_items')
      .select('collection_id')
      .eq('meal_id', mealId)
      .eq('user_id', auth.id);

  return (rows as List<dynamic>)
      .map((r) => r['collection_id'] as String)
      .toSet();
});

final collectionMealsProvider = FutureProvider.family<List<CollectionMeal>, String>((ref, collectionId) async {
  final supabase = ref.watch(supabaseProvider);

  final rows = await supabase
      .from('bookmark_items')
      .select('''
        meal_id, created_at,
        meals!inner(id, date, time, price_amount, heaviness, feeling,
          meal_foods(id, food_name),
          meal_photos(id, storage_path, sort_order),
          restaurants(id, name),
          branches(id, name))
      ''')
      .eq('collection_id', collectionId)
      .order('created_at', ascending: false);

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) {
        final meal = r['meals'] as Map<String, dynamic>;
        final photos = (meal['meal_photos'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .where((p) => p['storage_path'] != null)
            .toList() ?? [];
        if (photos.isEmpty) return null;

        final foods = (meal['meal_foods'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map((f) => f['food_name'] as String)
                .toList() ?? [];

        return CollectionMeal(
          mealId: meal['id'] as String,
          date: DateTime.parse(meal['date'] as String),
          thumbnailUrl: resolvePhotoUrl(supabase, photos.first['storage_path'] as String),
          photoCount: photos.length,
          foods: foods,
          restaurantName: (meal['restaurants'] as Map<String, dynamic>?)?['name'] as String?,
        );
      })
      .whereType<CollectionMeal>()
      .toList();
});

class CollectionMeal {
  final String mealId;
  final DateTime date;
  final String thumbnailUrl;
  final int photoCount;
  final List<String> foods;
  final String? restaurantName;

  CollectionMeal({
    required this.mealId,
    required this.date,
    required this.thumbnailUrl,
    required this.photoCount,
    required this.foods,
    this.restaurantName,
  });
}

final bookmarkActionsProvider = Provider<BookmarkActions>((ref) {
  return BookmarkActions(ref.watch(supabaseProvider), ref);
});

class BookmarkActions {
  final SupabaseClient _supabase;
  final Ref _ref;

  BookmarkActions(this._supabase, this._ref);

  Future<String> createCollection(String name) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Check for duplicate name
    final existing = await _supabase
        .from('bookmark_collections')
        .select('id')
        .eq('user_id', userId)
        .eq('name', name)
        .maybeSingle();
    if (existing != null) throw Exception('A collection with this name already exists');

    final rows = await _supabase.from('bookmark_collections').insert({
      'user_id': userId,
      'name': name,
    }).select('id');

    return ((rows as List<dynamic>).first as Map<String, dynamic>)['id'] as String;
  }

  Future<void> deleteCollection(String collectionId) async {
    await _supabase.from('bookmark_collections').delete().eq('id', collectionId);
  }

  Future<void> renameCollection(String collectionId, String newName) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Check for duplicate name (excluding the one being renamed)
    final existing = await _supabase
        .from('bookmark_collections')
        .select('id')
        .eq('user_id', userId)
        .eq('name', newName)
        .neq('id', collectionId)
        .maybeSingle();
    if (existing != null) throw Exception('A collection with this name already exists');

    await _supabase.from('bookmark_collections').update({'name': newName}).eq('id', collectionId);
  }

  Future<void> addMealToCollection(String collectionId, String mealId) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('bookmark_items').upsert({
      'collection_id': collectionId,
      'meal_id': mealId,
      'user_id': userId,
    }, onConflict: 'collection_id,meal_id');
  }

  Future<void> removeMealFromCollection(String collectionId, String mealId) async {
    await _supabase
        .from('bookmark_items')
        .delete()
        .eq('collection_id', collectionId)
        .eq('meal_id', mealId);
  }
}
