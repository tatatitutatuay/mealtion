import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';

final friendActionsProvider = Provider<FriendActions>((ref) {
  return FriendActions(ref.watch(supabaseProvider), ref);
});

class FriendActions {
  final SupabaseClient _supabase;
  final Ref _ref;

  FriendActions(this._supabase, this._ref);

  Future<void> sendRequest(String targetUserId) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase.from('friends').insert({
      'user_id': userId,
      'friend_user_id': targetUserId,
      'status': 'pending',
      'action_user_id': userId,
    });
  }

  Future<void> acceptRequest(String requesterId) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('friends')
        .update({'status': 'active'})
        .eq('user_id', requesterId)
        .eq('friend_user_id', userId);
  }

  Future<void> rejectRequest(String requesterId) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('friends')
        .delete()
        .eq('user_id', requesterId)
        .eq('friend_user_id', userId);
  }

  Future<void> removeFriend(String friendId) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('friends')
        .delete()
        .or('and(user_id.eq.$userId,friend_user_id.eq.$friendId),and(user_id.eq.$friendId,friend_user_id.eq.$userId)')
        .eq('status', 'active');
  }
}
