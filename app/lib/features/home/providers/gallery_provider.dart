import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';

class GalleryItem {
  final String mealId;
  final DateTime date;
  final String thumbnailUrl;
  final List<String> foods;

  GalleryItem({
    required this.mealId,
    required this.date,
    required this.thumbnailUrl,
    required this.foods,
  });
}

final galleryProvider = FutureProvider<List<GalleryItem>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);

  final rows = await supabase
      .from('meals')
      .select('''
        id, date,
        meal_foods(id, food_name),
        meal_photos(id, storage_path, sort_order)
      ''')
      .eq('user_id', auth.id)
      .order('date', ascending: false)
      .limit(50);

  final items = <GalleryItem>[];
  for (final row in (rows as List<dynamic>).cast<Map<String, dynamic>>()) {
    final photos = (row['meal_photos'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        ?.where((p) => p['storage_path'] != null)
        .toList() ?? [];
    if (photos.isEmpty) continue;

    final foods = (row['meal_foods'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            ?.map((f) => f['food_name'] as String)
            .toList() ?? [];

    items.add(GalleryItem(
      mealId: row['id'] as String,
      date: DateTime.parse(row['date'] as String),
      thumbnailUrl: photos.first['storage_path'] as String,
      foods: foods,
    ));
  }
  return items;
});
