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
        meal_foods(id, food_name),
        meal_photos(id, storage_path, sort_order)
      ''')
      .in_('user_id', friendIds)
      .eq('is_private', false)
      .order('date', ascending: false)
      .order('time', ascending: false)
      .limit(20);

  final posts = <FeedPost>[];
  for (final row in (rows as List<dynamic>).cast<Map<String, dynamic>>()) {
    final ownerId = row['user_id'] as String;
    final profiles = await supabase
        .from('profiles')
        .select('display_name, photo_url')
        .eq('id', ownerId)
        .limit(1);

    final profile = (profiles as List<dynamic>).isNotEmpty
        ? profiles.first as Map<String, dynamic>
        : <String, dynamic>{};

    final foods = (row['meal_foods'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            ?.map((f) => f['food_name'] as String)
            .toList() ?? [];

    final firstPhoto = (row['meal_photos'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        ?.where((p) => p['storage_path'] != null)
        .toList();

    posts.add(FeedPost(
      id: row['id'] as String,
      userId: ownerId,
      displayName: profile['display_name'] as String? ?? '',
      photoUrl: profile['photo_url'] as String?,
      date: DateTime.parse(row['date'] as String),
      restaurantName: (row['restaurants'] as Map<String, dynamic>?)?['name'] as String?,
      branchName: (row['branches'] as Map<String, dynamic>?)?['name'] as String?,
      price: (row['price_amount'] as num?)?.toDouble(),
      heaviness: row['heaviness'] as String?,
      feeling: row['feeling'] as String?,
      note: row['note'] as String?,
      foods: foods,
      thumbnailUrl: firstPhoto?.isNotEmpty == true ? firstPhoto!.first['storage_path'] as String : null,
    ));
  }
  return posts;
});

final friendsListProvider = FutureProvider<List<FriendProfile>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);
  final userId = auth.id;

  final rows = await supabase
      .from('friends')
      .select('friend_user_id')
      .eq('user_id', userId)
      .eq('status', 'active');

  final friendIds = (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => r['friend_user_id'] as String)
      .toList();

  if (friendIds.isEmpty) return [];

  final profileRows = await supabase
      .from('profiles')
      .select('id, display_name, username, bio, photo_url')
      .in_('id', friendIds);

  return (profileRows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => FriendProfile.fromJson(r))
      .toList();
});

final pendingRequestsProvider = FutureProvider<List<FriendProfile>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);
  final userId = auth.id;

  final rows = await supabase
      .from('friends')
      .select('user_id')
      .eq('friend_user_id', userId)
      .eq('status', 'pending');

  final requesterIds = (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => r['user_id'] as String)
      .toList();

  if (requesterIds.isEmpty) return [];

  final profileRows = await supabase
      .from('profiles')
      .select('id, display_name, username, bio, photo_url')
      .in_('id', requesterIds);

  return (profileRows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => FriendProfile.fromJson(r))
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

final userProfileProvider = FutureProvider.family<FriendProfile?, String>((ref, userId) async {
  final supabase = ref.watch(supabaseProvider);
  final rows = await supabase
      .from('profiles')
      .select('id, display_name, username, bio, photo_url')
      .eq('id', userId)
      .limit(1);

  final list = rows as List<dynamic>;
  if (list.isEmpty) return null;
  return FriendProfile.fromJson(list.first as Map<String, dynamic>);
});
