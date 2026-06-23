import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/friends_models.dart';
import '../providers/friends_providers.dart';

class FriendRequestsScreen extends ConsumerStatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  ConsumerState<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends ConsumerState<FriendRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _receivedTab(),
          _sentTab(),
        ],
      ),
    );
  }

  Widget _receivedTab() {
    final requests = ref.watch(pendingRequestsProvider);

    return requests.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text('No pending requests', style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.layoutMargin),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) => _receivedTile(items[i]),
        );
      },
    );
  }

  Widget _sentTab() {
    final requests = ref.watch(sentRequestsProvider);

    return requests.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text('No sent requests', style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.layoutMargin),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) => _sentTile(items[i]),
        );
      },
    );
  }

  Widget _receivedTile(FriendProfile user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.grey100,
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(user.displayName[0].toUpperCase(), style: AppTypography.b3)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.displayName, style: AppTypography.b3),
              if (user.username != null)
                Text('@${user.username}', style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check, color: AppColors.success),
          onPressed: () => acceptFriendRequest(ref, user.id),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.error),
          onPressed: () => rejectFriendRequest(ref, user.id),
        ),
      ],
    );
  }

  Widget _sentTile(FriendProfile user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.grey100,
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(user.displayName[0].toUpperCase(), style: AppTypography.b3)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.displayName, style: AppTypography.b3),
              if (user.username != null)
                Text('@${user.username}', style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(AppSpacing.radiusTiny),
          ),
          child: Text('Pending', style: AppTypography.c3.copyWith(color: AppColors.textSecondary)),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.error),
          onPressed: () => cancelSentRequest(ref, user.id),
        ),
      ],
    );
  }
}
