import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';

class GalleryItem {
  final String mealId;
  final DateTime date;
  final String? time;
  final String thumbnailUrl;
  final List<String> photoUrls;
  final List<String> foods;
  final String? restaurantName;
  final String? branchName;
  final double? price;
  final String? heaviness;
  final String? feeling;
  final bool isPrivate;

  GalleryItem({
    required this.mealId,
    required this.date,
    this.time,
    required this.thumbnailUrl,
    required this.photoUrls,
    required this.foods,
    this.restaurantName,
    this.branchName,
    this.price,
    this.heaviness,
    this.feeling,
    this.isPrivate = false,
  });

  bool get hasMultiplePhotos => photoUrls.length > 1;
}

final galleryProvider = FutureProvider.family<List<GalleryItem>, DateTime>((ref, month) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);

  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 0);
  final monthStartStr = monthStart.toIso8601String().split('T')[0];
  final monthEndStr = monthEnd.toIso8601String().split('T')[0];

  final rows = await supabase
      .from('meals')
      .select('''
        id, date, time, price_amount, heaviness, feeling, is_private,
        meal_foods(id, food_name),
        meal_photos(id, storage_path, sort_order),
        restaurants(id, name),
        branches(id, name)
      ''')
      .eq('user_id', auth.id)
      .gte('date', monthStartStr)
      .lte('date', monthEndStr)
      .order('date', ascending: false)
      .order('time', ascending: false);

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((row) {
        final photos = (row['meal_photos'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .where((p) => p['storage_path'] != null)
            .toList() ?? [];

        if (photos.isEmpty) return null;

        final foods = (row['meal_foods'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map((f) => f['food_name'] as String)
                .toList() ?? [];

        return GalleryItem(
          mealId: row['id'] as String,
          date: DateTime.parse(row['date'] as String),
          time: row['time'] as String?,
          thumbnailUrl: resolvePhotoUrl(supabase, photos.first['storage_path'] as String),
          photoUrls: photos.map((p) => resolvePhotoUrl(supabase, p['storage_path'] as String)).toList(),
          foods: foods,
          restaurantName: (row['restaurants'] as Map<String, dynamic>?)?['name'] as String?,
          branchName: (row['branches'] as Map<String, dynamic>?)?['name'] as String?,
          price: (row['price_amount'] as num?)?.toDouble(),
          heaviness: row['heaviness'] as String?,
          feeling: row['feeling'] as String?,
          isPrivate: row['is_private'] as bool? ?? false,
        );
      })
      .whereType<GalleryItem>()
      .toList();
});

final gallerySearchProvider = FutureProvider.family<List<GalleryItem>, String>((ref, query) async {
  final auth = ref.watch(authProvider);
  if (auth == null || query.trim().isEmpty) return [];
  final supabase = ref.watch(supabaseProvider);
  final q = query.trim();

  final rows = await supabase
      .from('meals')
      .select('''
        id, date, time, price_amount, heaviness, feeling, is_private,
        meal_foods(id, food_name),
        meal_photos(id, storage_path, sort_order),
        restaurants(id, name),
        branches(id, name)
      ''')
      .eq('user_id', auth.id)
      .or('meal_foods.food_name.ilike.%$q%,restaurants.name.ilike.%$q%,branches.name.ilike.%$q%')
      .order('date', ascending: false)
      .order('time', ascending: false)
      .limit(50);

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((row) {
        final photos = (row['meal_photos'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .where((p) => p['storage_path'] != null)
            .toList() ?? [];

        if (photos.isEmpty) return null;

        final foods = (row['meal_foods'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map((f) => f['food_name'] as String)
                .toList() ?? [];

        return GalleryItem(
          mealId: row['id'] as String,
          date: DateTime.parse(row['date'] as String),
          time: row['time'] as String?,
          thumbnailUrl: resolvePhotoUrl(supabase, photos.first['storage_path'] as String),
          photoUrls: photos.map((p) => resolvePhotoUrl(supabase, p['storage_path'] as String)).toList(),
          foods: foods,
          restaurantName: (row['restaurants'] as Map<String, dynamic>?)?['name'] as String?,
          branchName: (row['branches'] as Map<String, dynamic>?)?['name'] as String?,
          price: (row['price_amount'] as num?)?.toDouble(),
          heaviness: row['heaviness'] as String?,
          feeling: row['feeling'] as String?,
          isPrivate: row['is_private'] as bool? ?? false,
        );
      })
      .whereType<GalleryItem>()
      .toList();
});
