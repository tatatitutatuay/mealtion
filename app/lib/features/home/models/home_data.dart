import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';

class HomeMealEntry {
  final String id;
  final DateTime date;
  final String? restaurantName;
  final String? branchName;
  final double? price;
  final String? heaviness;
  final String? feeling;
  final String? note;
  final List<String> foods;
  final String? thumbnailUrl;
  final bool isPrivate;

  HomeMealEntry({
    required this.id,
    required this.date,
    this.restaurantName,
    this.branchName,
    this.price,
    this.heaviness,
    this.feeling,
    this.note,
    required this.foods,
    this.thumbnailUrl,
    this.isPrivate = false,
  });

  factory HomeMealEntry.fromJson(Map<String, dynamic> json, {SupabaseClient? supabase}) {
    final mealFoods = (json['meal_foods'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            ?.map((f) => f['food_name'] as String)
            .toList() ??
        [];

    final firstPhoto = (json['meal_photos'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            ?.where((p) => p['storage_path'] != null)
            .toList()
            ?.isNotEmpty == true
        ? (json['meal_photos'] as List<dynamic>).first as Map<String, dynamic>
        : null;

    final restaurantName =
        (json['restaurants'] as Map<String, dynamic>?)?['name'] as String?;
    final branchName =
        (json['branches'] as Map<String, dynamic>?)?['name'] as String?;

    return HomeMealEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      restaurantName: restaurantName,
      branchName: branchName,
      price: (json['price_amount'] as num?)?.toDouble(),
      heaviness: json['heaviness'] as String?,
      feeling: json['feeling'] as String?,
      note: json['note'] as String?,
      foods: mealFoods,
      thumbnailUrl: firstPhoto != null && supabase != null
          ? resolvePhotoUrl(supabase, firstPhoto['storage_path'] as String)
          : firstPhoto?['storage_path'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
    );
  }
}

class CalendarMealInfo {
  final DateTime date;
  final String? heaviness;
  final String? feeling;
  final double? price;

  CalendarMealInfo({required this.date, this.heaviness, this.feeling, this.price});
}

class HomeDashboardData {
  final String displayName;
  final String? photoUrl;
  final int totalMealsThisMonth;
  final int totalFoodsThisMonth;
  final int totalRestaurantsThisMonth;
  final double totalSpentThisMonth;
  final List<DateTime> mealDatesThisMonth;
  final List<CalendarMealInfo> mealInfosThisMonth;
  final List<HomeMealEntry> recentMeals;

  HomeDashboardData({
    required this.displayName,
    this.photoUrl,
    required this.totalMealsThisMonth,
    required this.totalFoodsThisMonth,
    required this.totalRestaurantsThisMonth,
    required this.totalSpentThisMonth,
    required this.mealDatesThisMonth,
    required this.mealInfosThisMonth,
    required this.recentMeals,
  });
}
