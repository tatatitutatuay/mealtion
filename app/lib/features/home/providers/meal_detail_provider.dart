import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';

class MealDetail {
  final String id;
  final String userId;
  final DateTime date;
  final String? time;
  final String source;
  final List<String> photoUrls;
  final List<String> foods;
  final List<String> tags;
  final String? restaurantName;
  final String? branchName;
  final double? price;
  final String? heaviness;
  final String? feeling;
  final String? note;
  final bool isPrivate;

  MealDetail({
    required this.id,
    required this.userId,
    required this.date,
    this.time,
    required this.source,
    required this.photoUrls,
    required this.foods,
    this.tags = const [],
    this.restaurantName,
    this.branchName,
    this.price,
    this.heaviness,
    this.feeling,
    this.note,
    this.isPrivate = false,
  });
}

final mealDetailProvider = FutureProvider.family<MealDetail, String>((ref, mealId) async {
  final auth = ref.watch(authProvider);
  if (auth == null) throw Exception('Not authenticated');
  final supabase = ref.watch(supabaseProvider);

  final row = await supabase
      .from('meals')
      .select('''
        id, user_id, date, time, source, price_amount, heaviness, feeling,
        note, is_private,
        meal_photos(id, storage_path, sort_order),
        meal_foods(id, food_name, sort_order),
        meal_tags(id, tag_name),
        restaurants(id, name),
        branches(id, name)
      ''')
      .eq('id', mealId)
      .maybeSingle();

  if (row == null) throw Exception('Meal not found');

  final photos = (row['meal_photos'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .where((p) => p['storage_path'] != null)
          .toList() ??
      [];
  photos.sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));

  final foods = (row['meal_foods'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .toList() ??
      [];
  foods.sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));

  final tags = (row['meal_tags'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map((t) => t['tag_name'] as String)
          .toList() ??
      [];

  return MealDetail(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    date: DateTime.parse(row['date'] as String),
    time: row['time'] as String?,
    source: row['source'] as String,
    photoUrls: photos.map((p) => resolvePhotoUrl(supabase, p['storage_path'] as String)).toList(),
    foods: foods.map((f) => f['food_name'] as String).toList(),
    tags: tags,
    restaurantName: (row['restaurants'] as Map<String, dynamic>?)?['name'] as String?,
    branchName: (row['branches'] as Map<String, dynamic>?)?['name'] as String?,
    price: (row['price_amount'] as num?)?.toDouble(),
    heaviness: row['heaviness'] as String?,
    feeling: row['feeling'] as String?,
    note: row['note'] as String?,
    isPrivate: row['is_private'] as bool? ?? false,
  );
});

/// Fetch all meals for a specific date (used for calendar vertical swipe)
final mealsByDateProvider = FutureProvider.family<List<MealDetail>, DateTime>((ref, date) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);
  final dateStr = date.toIso8601String().split('T')[0];

  final rows = await supabase
      .from('meals')
      .select('''
        id, user_id, date, time, source, price_amount, heaviness, feeling,
        note, is_private,
        meal_photos(id, storage_path, sort_order),
        meal_foods(id, food_name, sort_order),
        meal_tags(id, tag_name),
        restaurants(id, name),
        branches(id, name)
      ''')
      .eq('user_id', auth.id)
      .eq('date', dateStr)
      .order('time', ascending: true);

  return (rows as List<dynamic>).cast<Map<String, dynamic>>().map((row) {
    final photos = (row['meal_photos'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .where((p) => p['storage_path'] != null)
            .toList() ??
        [];
    photos.sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));

    final foods = (row['meal_foods'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .toList() ??
        [];
    foods.sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));

    final tags = (row['meal_tags'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .map((t) => t['tag_name'] as String)
            .toList() ??
        [];

    return MealDetail(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      date: DateTime.parse(row['date'] as String),
      time: row['time'] as String?,
      source: row['source'] as String,
      photoUrls: photos.map((p) => resolvePhotoUrl(supabase, p['storage_path'] as String)).toList(),
      foods: foods.map((f) => f['food_name'] as String).toList(),
      tags: tags,
      restaurantName: (row['restaurants'] as Map<String, dynamic>?)?['name'] as String?,
      branchName: (row['branches'] as Map<String, dynamic>?)?['name'] as String?,
      price: (row['price_amount'] as num?)?.toDouble(),
      heaviness: row['heaviness'] as String?,
      feeling: row['feeling'] as String?,
      note: row['note'] as String?,
      isPrivate: row['is_private'] as bool? ?? false,
    );
  }).toList();
});
