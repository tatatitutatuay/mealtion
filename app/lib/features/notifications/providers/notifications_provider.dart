import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';

class NotificationItem {
  final String id;
  final String type;
  final String? actorName;
  final String? actorPhotoUrl;
  final String? mealId;
  final int groupCount;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    this.actorName,
    this.actorPhotoUrl,
    this.mealId,
    this.groupCount = 1,
    this.isRead = false,
    required this.createdAt,
  });

  String get label => switch (type) {
        'friend_request' => 'sent you a friend request',
        'friend_accepted' => 'accepted your friend request',
        'like' => 'liked your meal',
        'comment' => 'commented on your meal',
        _ => 'interacted with you',
      };
}

final notificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser!.id;

  final rows = await supabase
      .from('notifications')
      .select('''
        id, type, actor_id, meal_id, group_count, is_read, created_at,
        actor:profiles!actor_id(display_name, photo_url)
      ''')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(50);

  return (rows as List<dynamic>).cast<Map<String, dynamic>>().map((row) {
    final actor = row['actor'] as Map<String, dynamic>?;
    return NotificationItem(
      id: row['id'] as String,
      type: row['type'] as String,
      actorName: actor?['display_name'] as String?,
      actorPhotoUrl: actor?['photo_url'] as String?,
      mealId: row['meal_id'] as String?,
      groupCount: row['group_count'] as int? ?? 1,
      isRead: row['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }).toList();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser!.id;

  final result = await supabase
      .from('notifications')
      .select('id')
      .eq('user_id', userId)
      .eq('is_read', false);

  return (result as List<dynamic>).length;
});
