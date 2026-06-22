import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/friends_models.dart';

final friendsFeedProvider = FutureProvider<List<FeedPost>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);
  final userId = auth.id;

  final friendRows = await supabase
      .from('friends')
      .select('friend_user_id')
      .eq('user_id', userId)
      .eq('status', 'active');

  final friendIds = (friendRows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => r['friend_user_id'] as String)
      .toList();

  if (friendIds.isEmpty) return [];

  final rows = await supabase
      .from('meals')
      .select('''
        id, user_id, date, time, restaurant_id, branch_id, price_amount,
        heaviness, feeling, note, is_private,
        profiles!meals_user_id_fkey(id, display_name, photo_url),
        restaurants(id, name),
        branches(id, name),
        meal_foods(id, food_name),
        meal_photos(id, storage_path, sort_order)
      ''')
      .in_('user_id', friendIds)
      .eq('is_private', false)
      .order('date', ascending: false)
      .order('time', ascending: false)
      .limit(20);

  return (rows as List<dynamic>).map((r) => _parsePost(r)).toList();
});

final friendsListProvider = FutureProvider<List<FriendProfile>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);
  final userId = auth.id;

  final rows = await supabase
      .from('friends')
      .select('friend_user_id, profiles!friends_friend_user_id_fkey(id, display_name, username, bio, photo_url)')
      .eq('user_id', userId)
      .eq('status', 'active');

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => FriendProfile.fromJson(r['profiles'] as Map<String, dynamic>? ?? {}))
      .toList();
});

final pendingRequestsProvider = FutureProvider<List<FriendProfile>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);
  final userId = auth.id;

  final rows = await supabase
      .from('friends')
      .select('user_id, profiles!friends_user_id_fkey(id, display_name, username, bio, photo_url)')
      .eq('friend_user_id', userId)
      .eq('status', 'pending');

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => FriendProfile.fromJson(r['profiles'] as Map<String, dynamic>? ?? {}))
      .toList();
});

final searchUsersProvider = FutureProvider.family<List<FriendProfile>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final supabase = ref.watch(supabaseProvider);
  final currentUserId = ref.watch(authProvider)?.id;
  if (currentUserId == null) return [];

  final rows = await supabase
      .from('profiles')
      .select('id, display_name, username, bio, photo_url')
      .or('username.ilike.%$query%,display_name.ilike.%$query%')
      .neq('id', currentUserId)
      .limit(20);

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => FriendProfile.fromJson(r))
      .toList();
});

FeedPost _parsePost(Map<String, dynamic> json) {
  final profile = json['profiles'] as Map<String, dynamic>?;
  final foods = (json['meal_foods'] as List<dynamic>?)
      ?.cast<Map<String, dynamic>>()
      ?.map((f) => f['food_name'] as String)
      .toList() ?? [];

  final firstPhoto = (json['meal_photos'] as List<dynamic>?)
      ?.cast<Map<String, dynamic>>()
      ?.where((p) => p['storage_path'] != null)
      .toList()
      ?.isNotEmpty == true
      ? (json['meal_photos'] as List<dynamic>).first as Map<String, dynamic>
      : null;

  return FeedPost(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    displayName: profile?['display_name'] as String? ?? '',
    photoUrl: profile?['photo_url'] as String?,
    date: DateTime.parse(json['date'] as String),
    restaurantName: (json['restaurants'] as Map<String, dynamic>?)?['name'] as String?,
    branchName: (json['branches'] as Map<String, dynamic>?)?['name'] as String?,
    price: (json['price_amount'] as num?)?.toDouble(),
    heaviness: json['heaviness'] as String?,
    feeling: json['feeling'] as String?,
    note: json['note'] as String?,
    foods: foods,
    thumbnailUrl: firstPhoto?['storage_path'] as String?,
  );
}
