import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/shadows.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/friends_models.dart';
import '../providers/friends_providers.dart';
import '../providers/friend_actions.dart';
import 'connect_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConnectScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _tabBar(),
          Expanded(
            child: _tabIndex == 0 ? _feedTab() : _friendsTab(),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Row(
        children: [
          _tab('Feed', 0),
          const SizedBox(width: 24),
          _tab('Friends', 1),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Column(
        children: [
          Text(label, style: (selected ? AppTypography.s2 : AppTypography.b3).copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          )),
          if (selected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 24,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _feedTab() {
    final feed = ref.watch(friendsFeedProvider);
    return feed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (posts) => posts.isEmpty
          ? const Center(child: Text('No posts from friends yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.layoutMargin),
              itemCount: posts.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _feedPostCard(posts[i]),
              ),
            ),
    );
  }

  Widget _friendsTab() {
    final friends = ref.watch(friendsListProvider);
    return friends.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (list) => list.isEmpty
          ? const Center(child: Text('No friends yet'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 16),
              itemCount: list.length,
              itemBuilder: (_, i) => _friendTile(list[i]),
            ),
    );
  }

  Widget _feedPostCard(FeedPost post) {
    final feelingColor = switch (post.feeling) {
      'like' => AppColors.success,
      'neutral' => AppColors.warning,
      'dislike' => AppColors.error,
      _ => AppColors.grey500,
    };
    final feelingLabel = switch (post.feeling) {
      'like' => 'Like',
      'neutral' => 'Neutral',
      'dislike' => 'Dislike',
      _ => '',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.grey100,
                  backgroundImage: post.photoUrl != null ? NetworkImage(post.photoUrl!) : null,
                  child: post.photoUrl == null
                      ? Text(post.displayName[0].toUpperCase(),
                          style: AppTypography.b6.copyWith(color: AppColors.textSecondary))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(post.displayName, style: AppTypography.s2)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Container(
              height: 200,
              width: double.infinity,
              color: AppColors.grey100,
              child: post.thumbnailUrl != null
                  ? Image.network(post.thumbnailUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.restaurant, size: 48, color: AppColors.grey500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.foods.join(', '), style: AppTypography.s2),
                const SizedBox(height: 2),
                if (post.restaurantName != null)
                  Text('${post.restaurantName}${post.branchName != null ? ' (${post.branchName})' : ''}',
                      style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (post.price != null)
                      Text('${post.price!.toStringAsFixed(0)} ฿', style: AppTypography.b4),
                    if (post.price != null && feelingLabel.isNotEmpty)
                      const SizedBox(width: 8),
                    if (feelingLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: feelingColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
                        ),
                        child: Text(feelingLabel,
                            style: AppTypography.c3.copyWith(color: feelingColor)),
                      ),
                  ],
                ),
                if (post.note != null && post.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(post.note!, style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 18, color: AppColors.grey500),
                    const SizedBox(width: 4),
                    Text('${post.likeCount}', style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.grey500),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}', style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
                    const Spacer(),
                    const Icon(Icons.bookmark_border, size: 18, color: AppColors.grey500),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendTile(FriendProfile friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.grey100,
            backgroundImage: friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
            child: friend.photoUrl == null
                ? Text(friend.displayName[0].toUpperCase(),
                    style: AppTypography.s1.copyWith(color: AppColors.grey500))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.displayName, style: AppTypography.s2),
                if (friend.bio != null && friend.bio!.isNotEmpty)
                  Text(friend.bio!, style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
            ),
            child: Text('Friends', style: AppTypography.c2.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
