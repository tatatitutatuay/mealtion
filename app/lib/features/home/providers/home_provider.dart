import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/home_data.dart';

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) throw Exception('Not authenticated');

  final supabase = ref.watch(supabaseProvider);
  final userId = auth.id;
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  // 1. Meal dates for calendar this month
  final mealDateRows = await supabase
      .from('meals')
      .select('date')
      .eq('user_id', userId)
      .gte('date', monthStart.toIso8601String().split('T')[0])
      .lte('date', monthEnd.toIso8601String().split('T')[0]);

  final mealDates = (mealDateRows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => DateTime.parse(r['date'] as String))
      .toSet()
      .toList();

  // 2. Monthly aggregates
  final mealsThisMonth = await supabase
      .from('meals')
      .select('id, price_amount, restaurant_id')
      .eq('user_id', userId)
      .gte('date', monthStart.toIso8601String().split('T')[0])
      .lte('date', monthEnd.toIso8601String().split('T')[0]);

  final mealRows = mealsThisMonth as List<dynamic>;
  final totalMeals = mealRows.length;

  final restaurantIds = mealRows
      .cast<Map<String, dynamic>>()
      .where((r) => r['restaurant_id'] != null)
      .map((r) => r['restaurant_id'] as String)
      .toSet()
      .length;

  final totalSpent = mealRows
      .cast<Map<String, dynamic>>()
      .where((r) => r['price_amount'] != null)
      .fold<double>(0, (sum, r) => sum + (r['price_amount'] as num).toDouble());

  int totalFoods = 0;
  if (mealRows.isNotEmpty) {
    final foodRows = await supabase
        .from('meal_foods')
        .select('food_name')
        .in_('meal_id', mealRows.cast<Map<String, dynamic>>().map((r) => r['id'] as String).toList());

    totalFoods = (foodRows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((r) => r['food_name'] as String)
        .toSet()
        .length;
  }

  // 4. Recent 3 meals with foods + photos + restaurant info
  final recentRows = await supabase
      .from('meals')
      .select('''
        id, date, time, restaurant_id, branch_id, price_amount, 
        heaviness, feeling, note, is_private,
        restaurants(id, name),
        branches(id, name),
        meal_foods(id, food_name, sort_order),
        meal_photos(id, storage_path, sort_order)
      ''')
      .eq('user_id', userId)
      .order('date', ascending: false)
      .order('time', ascending: false)
      .limit(10);

  final recentList = (recentRows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((j) => HomeMealEntry.fromJson(j))
      .take(3)
      .toList();

  return HomeDashboardData(
    displayName: auth.displayName,
    photoUrl: auth.photoUrl,
    totalMealsThisMonth: totalMeals,
    totalFoodsThisMonth: totalFoods,
    totalRestaurantsThisMonth: restaurantIds,
    totalSpentThisMonth: totalSpent,
    mealDatesThisMonth: mealDates,
    recentMeals: recentList,
  );
});
