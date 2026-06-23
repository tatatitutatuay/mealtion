import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';

final engagementProvider = Provider<EngagementActions>((ref) {
  return EngagementActions(ref.watch(supabaseProvider), ref);
});

class EngagementActions {
  final SupabaseClient _supabase;
  final Ref _ref;

  EngagementActions(this._supabase, this._ref);

  Future<void> toggleLike(String mealId) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    final existing = await _supabase
        .from('likes')
        .select('id')
        .eq('user_id', userId)
        .eq('meal_id', mealId)
        .limit(1);

    if ((existing as List<dynamic>).isNotEmpty) {
      await _supabase
          .from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('meal_id', mealId);
    } else {
      await _supabase.from('likes').insert({
        'user_id': userId,
        'meal_id': mealId,
      });
    }
  }

  Future<void> addComment(String mealId, String body) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');
    if (body.trim().isEmpty) return;

    await _supabase.from('comments').insert({
      'user_id': userId,
      'meal_id': mealId,
      'body': body.trim(),
    });
  }

  Future<void> deleteComment(String commentId) async {
    final userId = _ref.read(authProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _supabase
        .from('comments')
        .delete()
        .eq('id', commentId)
        .eq('user_id', userId);
  }
}

final mealCommentsProvider = FutureProvider.family<List<CommentRow>, String>((ref, mealId) async {
  final supabase = ref.watch(supabaseProvider);
  final rows = await supabase
      .from('comments')
      .select('''
        id, user_id, body, created_at,
        profiles:user_id(display_name, photo_url)
      ''')
      .eq('meal_id', mealId)
      .order('created_at', ascending: true);

  return (rows as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map((r) => CommentRow.fromJson(r))
      .toList();
});

class CommentRow {
  final String id;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String body;
  final DateTime createdAt;

  CommentRow({
    required this.id,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.body,
    required this.createdAt,
  });

  factory CommentRow.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>? ?? {};
    return CommentRow(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: profile['display_name'] as String? ?? '',
      photoUrl: profile['photo_url'] as String?,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
