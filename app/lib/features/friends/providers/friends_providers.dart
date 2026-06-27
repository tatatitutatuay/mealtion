import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Include own posts in the feed
  final feedUserIds = [...friendIds, userId];

  final rows = await supabase
      .from('meals')
      .select('''
        id, user_id, date, time, restaurant_id, branch_id, price_amount,
        heaviness, feeling, note, is_private,
        meal_foods(id, food_name),
        meal_photos(id, storage_path, sort_order),
        profiles:user_id(display_name, photo_url),
        restaurants(id, name),
        branches(id, name),
        likes(id, user_id),
        comments(id, user_id, body, created_at)
      ''')
      .inFilter('user_id', feedUserIds)
      .eq('is_private', false)
      .order('date', ascending: false)
      .order('time', ascending: false)
      .limit(20);

  final posts = <FeedPost>[];
  for (final row in (rows as List<dynamic>).cast<Map<String, dynamic>>()) {
    final ownerId = row['user_id'] as String;
    final profile = row['profiles'] as Map<String, dynamic>? ?? {};

    final foods = (row['meal_foods'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .map((f) => f['food_name'] as String)
            .toList() ?? [];

    final firstPhoto = (row['meal_photos'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        .where((p) => p['storage_path'] != null)
        .toList();

    final likes = (row['likes'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final isLiked = likes.any((l) => l['user_id'] == userId);

    final comments = (row['comments'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final recentComments = comments.take(2).map((c) {
      return CommentPreview(
        userId: c['user_id'] as String,
        displayName: '',
        body: c['body'] as String,
        createdAt: c['created_at'] as String,
      );
    }).toList();

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
      thumbnailUrl: firstPhoto?.isNotEmpty == true ? resolvePhotoUrl(supabase, firstPhoto!.first['storage_path'] as String) : null,
      likeCount: likes.length,
      commentCount: comments.length,
      isLiked: isLiked,
      recentComments: recentComments,
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
      .inFilter('id', friendIds);

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
      .inFilter('id', requesterIds);

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
      .eq('username', query)
      .neq('id', currentUserId)
      .limit(20);

  // Fetch sent requests by current user to check pending status
  final sentRows = await supabase
      .from('friends')
      .select('friend_user_id, status')
      .eq('user_id', currentUserId);
  final sentMap = <String, String>{};
  for (final r in sentRows as List<dynamic>) {
    final row = r as Map<String, dynamic>;
    sentMap[row['friend_user_id'] as String] = row['status'] as String;
  }

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) {
        final id = r['id'] as String;
        return FriendProfile.fromJson(r).copyWith(friendStatus: sentMap[id]);
      })
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

/// Sent requests (pending requests sent by current user)
final sentRequestsProvider = FutureProvider<List<FriendProfile>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return [];
  final supabase = ref.watch(supabaseProvider);

  final rows = await supabase
      .from('friends')
      .select('friend_user_id')
      .eq('user_id', auth.id)
      .eq('status', 'pending');

  final targetIds = (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => r['friend_user_id'] as String)
      .toList();

  if (targetIds.isEmpty) return [];

  final profileRows = await supabase
      .from('profiles')
      .select('id, display_name, username, bio, photo_url')
      .inFilter('id', targetIds);

  return (profileRows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => FriendProfile.fromJson(r))
      .toList();
});

/// Accept a friend request (received)
Future<void> acceptFriendRequest(WidgetRef ref, String requesterId) async {
  final supabase = ref.read(supabaseProvider);
  final userId = supabase.auth.currentUser!.id;

  // Update received row to active
  await supabase
      .from('friends')
      .update({'status': 'active'})
      .eq('user_id', requesterId)
      .eq('friend_user_id', userId);

  // Create reciprocal row as active
  await supabase.from('friends').insert({
    'user_id': userId,
    'friend_user_id': requesterId,
    'status': 'active',
    'action_user_id': userId,
  });

  ref.invalidate(pendingRequestsProvider);
  ref.invalidate(friendsListProvider);
}

/// Reject a friend request (received)
Future<void> rejectFriendRequest(WidgetRef ref, String requesterId) async {
  final supabase = ref.read(supabaseProvider);
  final userId = supabase.auth.currentUser!.id;

  await supabase
      .from('friends')
      .delete()
      .eq('user_id', requesterId)
      .eq('friend_user_id', userId);

  ref.invalidate(pendingRequestsProvider);
}

/// Cancel a sent friend request
Future<void> cancelSentRequest(WidgetRef ref, String targetId) async {
  final supabase = ref.read(supabaseProvider);
  final userId = supabase.auth.currentUser!.id;

  await supabase
      .from('friends')
      .delete()
      .eq('user_id', userId)
      .eq('friend_user_id', targetId);

  ref.invalidate(sentRequestsProvider);
}
