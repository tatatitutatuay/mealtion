import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/friends_models.dart';
import '../providers/friends_providers.dart';
import '../providers/engagement_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/meal_detail_provider.dart';
import '../../home/widgets/meal_detail_sheet.dart';
import '../../home/widgets/meal_tags.dart';
import '../widgets/comment_sheet.dart';
import 'connect_screen.dart';
import 'friend_requests_screen.dart';
import 'friend_profile_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  int _tabIndex = 0;

  Future<void> _toggleLike(String mealId) async {
    try {
      await ref.read(engagementProvider).toggleLike(mealId);
      ref.invalidate(friendsFeedProvider);
      ref.invalidate(mealDetailProvider(mealId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  void _openComments(String mealId) {
    final userId = ref.read(authProvider)?.id;
    if (userId == null) return;
    CommentSheet.show(context, mealId, userId);
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(pendingRequestsProvider).valueOrNull?.length ?? 0;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(pendingCount),
            const SizedBox(height: 12),
            _tabBar(),
            Expanded(
              child: _tabIndex == 0 ? _feedTab() : _friendsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(int pendingCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Row(
        children: [
          Text('Friends', style: AppTypography.s1.copyWith(
              color: AppColors.textPrimary, fontSize: 20)),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FriendRequestsScreen()),
                ),
                child: Container(
                  width: 37,
                  height: 37,
                  decoration: const BoxDecoration(
                    border: AppSpacing.cardBorder,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.mail_outline, size: 16, color: AppColors.textPrimary),
                ),
              ),
              if (pendingCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.tagRed,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$pendingCount',
                      style: AppTypography.c3.copyWith(
                          color: AppColors.textPrimary, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConnectScreen()),
            ),
            child: Container(
              width: 37,
              height: 37,
              decoration: const BoxDecoration(
                border: AppSpacing.cardBorder,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person_add_outlined, size: 16, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tab('Feed', 0),
            _tab('Friends', 1),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          border: selected ? AppSpacing.cardBorder : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(label,
            style: AppTypography.b5.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
            textAlign: TextAlign.center),
      ),
    );
  }

  Widget _feedTab() {
    final feed = ref.watch(friendsFeedProvider);
    return feed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (posts) => posts.isEmpty
          ? RefreshIndicator(
              onRefresh: () async => ref.invalidate(friendsFeedProvider),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Text('No posts from friends yet')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(friendsFeedProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.layoutMargin, 16, AppSpacing.layoutMargin, 120),
                itemCount: posts.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _feedPostCard(posts[i]),
                ),
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
          ? RefreshIndicator(
              onRefresh: () async => ref.invalidate(friendsListProvider),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Text('No friends yet')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(friendsListProvider),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.layoutMargin, 16, AppSpacing.layoutMargin, 120),
                itemCount: list.length,
                itemBuilder: (_, i) => _friendTile(list[i]),
              ),
            ),
    );
  }

  Widget _feedPostCard(FeedPost post) {
    return Container(
      decoration: BoxDecoration(
        border: AppSpacing.cardBorder,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name + time + more
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => FriendProfileScreen(userId: post.userId)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: AppColors.grey100,
                        backgroundImage: post.photoUrl != null ? NetworkImage(post.photoUrl!) : null,
                        child: post.photoUrl == null
                            ? Text(post.displayName[0].toUpperCase(),
                                style: AppTypography.b6.copyWith(color: AppColors.textSecondary))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.displayName,
                              style: AppTypography.b5.copyWith(
                                  color: AppColors.textPrimary, fontSize: 12)),
                          Text('2h ago',
                              style: AppTypography.c3.copyWith(
                                  color: AppColors.textFaded, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, size: 24, color: AppColors.textPrimary),
              ],
            ),
          ),
          // Photo
          GestureDetector(
            onTap: () => MealDetailSheet.show(context, post.id, canEdit: false),
            child: Container(
              height: 247.5,
              width: double.infinity,
              color: AppColors.photoPlaceholder,
              child: post.thumbnailUrl != null
                  ? Image.network(post.thumbnailUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.restaurant, size: 48, color: AppColors.grey500),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.foods.join(', '),
                    style: AppTypography.b5.copyWith(
                        color: AppColors.textPrimary, fontSize: 12)),
                const SizedBox(height: 2),
                if (post.restaurantName != null)
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 12, color: AppColors.textPrimary),
                      const SizedBox(width: 4),
                      Text('${post.restaurantName}${post.branchName != null ? ' (${post.branchName})' : ''}',
                          style: AppTypography.b5.copyWith(
                              color: AppColors.textPrimary, fontSize: 12)),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (post.price != null && (ref.read(authProvider)?.priceDisplayPrivacy ?? 'actual') != 'hidden') ...[
                      MealTags.price(post.price!),
                      const SizedBox(width: 6),
                    ],
                    if (post.heaviness != null) ...[
                      MealTags.heaviness(post.heaviness!),
                      const SizedBox(width: 6),
                    ],
                    if (post.feeling != null)
                      MealTags.feeling(post.feeling!),
                  ],
                ),
                if (post.note != null && post.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(post.note!, style: AppTypography.b5.copyWith(
                      color: AppColors.textPrimary, fontSize: 12)),
                ],
              ],
            ),
          ),
          // Divider
          const Divider(height: 0, thickness: 0.5, color: AppColors.border),
          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(post.id),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: post.isLiked ? AppColors.error : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 7),
                      Text('${post.likeCount}', style: AppTypography.b5.copyWith(
                          color: AppColors.textPrimary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () => _openComments(post.id),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.textPrimary),
                      const SizedBox(width: 7),
                      Text('${post.commentCount}', style: AppTypography.b5.copyWith(
                          color: AppColors.textPrimary, fontSize: 12)),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => MealDetailSheet.showCollectionSelector(context, ref, post.id),
                  child: const Icon(Icons.bookmark_border, size: 18, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          if (post.recentComments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: post.recentComments.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: AppTypography.b5.copyWith(
                          color: AppColors.textPrimary, fontSize: 12),
                      children: [
                        TextSpan(
                          text: '${c.displayName.isEmpty ? "User" : c.displayName}: ',
                          style: AppTypography.b5.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary, fontSize: 12),
                        ),
                        TextSpan(text: c.body),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _friendTile(FriendProfile friend) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => FriendProfileScreen(userId: friend.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tagGreen,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text('Friends', style: AppTypography.c3.copyWith(
                  color: AppColors.textPrimary, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

}
