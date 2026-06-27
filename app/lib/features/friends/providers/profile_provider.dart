import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/profile_data.dart';

final myProfileProvider = FutureProvider<ProfileData>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) throw Exception('Not authenticated');
  final supabase = ref.watch(supabaseProvider);
  final userId = auth.id;

  final profileRows = await supabase
      .from('profiles')
      .select('display_name, username, bio, photo_url, cover_url')
      .eq('id', userId)
      .limit(1);

  final profileList = profileRows as List<dynamic>;
  final profileData = profileList.isNotEmpty
      ? profileList.first as Map<String, dynamic>
      : <String, dynamic>{};

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  final monthStartStr = monthStart.toIso8601String().split('T')[0];
  final monthEndStr = monthEnd.toIso8601String().split('T')[0];

  final mealsCount = await supabase
      .from('meals')
      .count(CountOption.exact)
      .eq('user_id', userId);

  final monthMeals = await supabase
      .from('meals')
      .select('id')
      .eq('user_id', userId)
      .gte('date', monthStartStr)
      .lte('date', monthEndStr);

  final monthMealIds = (monthMeals as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => r['id'] as String)
      .toList();

  int monthFoodsCount = 0;
  int monthRestaurantsCount = 0;
  if (monthMealIds.isNotEmpty) {
    final foodRows = await supabase
        .from('meal_foods')
        .select('food_name')
        .inFilter('meal_id', monthMealIds);
    monthFoodsCount = (foodRows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((r) => r['food_name'] as String)
        .toSet()
        .length;

    final restaurantRows = await supabase
        .from('meals')
        .select('restaurant_id')
        .inFilter('id', monthMealIds);
    monthRestaurantsCount = (restaurantRows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((r) => r['restaurant_id'] != null)
        .map((r) => r['restaurant_id'] as String)
        .toSet()
        .length;
  }

  final friendsCount = await supabase
      .from('friends')
      .count(CountOption.exact)
      .eq('user_id', userId)
      .eq('status', 'active');

  return ProfileData(
    displayName: profileData['display_name'] as String? ?? auth.displayName,
    username: profileData['username'] as String?,
    bio: profileData['bio'] as String?,
    photoUrl: (profileData['photo_url'] as String?)?.isNotEmpty == true
        ? profileData['photo_url'] as String?
        : null,
    coverUrl: (profileData['cover_url'] as String?)?.isNotEmpty == true
        ? profileData['cover_url'] as String?
        : null,
    totalMeals: mealsCount,
    monthMeals: monthMealIds.length,
    monthFoods: monthFoodsCount,
    monthRestaurants: monthRestaurantsCount,
    friendsCount: friendsCount,
  );
});

/// Profile data for any user (friend profile view)
final userProfileDataProvider = FutureProvider.family<ProfileData, String>((ref, userId) async {
  final supabase = ref.watch(supabaseProvider);

  final profileRows = await supabase
      .from('profiles')
      .select('display_name, username, bio, photo_url, cover_url')
      .eq('id', userId)
      .limit(1);

  final profileList = profileRows as List<dynamic>;
  final profileData = profileList.isNotEmpty
      ? profileList.first as Map<String, dynamic>
      : <String, dynamic>{};

  final mealsCount = await supabase
      .from('meals')
      .count(CountOption.exact)
      .eq('user_id', userId)
      .eq('is_private', false);

  final friendsCount = await supabase
      .from('friends')
      .count(CountOption.exact)
      .eq('user_id', userId)
      .eq('status', 'active');

  return ProfileData(
    displayName: profileData['display_name'] as String? ?? '',
    username: profileData['username'] as String?,
    bio: profileData['bio'] as String?,
    photoUrl: (profileData['photo_url'] as String?)?.isNotEmpty == true
        ? profileData['photo_url'] as String?
        : null,
    coverUrl: (profileData['cover_url'] as String?)?.isNotEmpty == true
        ? profileData['cover_url'] as String?
        : null,
    totalMeals: mealsCount,
    monthMeals: 0,
    monthFoods: 0,
    monthRestaurants: 0,
    friendsCount: friendsCount,
  );
});
