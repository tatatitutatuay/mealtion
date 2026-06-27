import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/friends_providers.dart';
import '../models/friends_models.dart';
import 'user_search_screen.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.layoutMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search username',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey500),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _hasSearched = false);
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) {
                setState(() => _hasSearched = true);
              },
            ),
            const SizedBox(height: 24),
            if (_hasSearched && _searchController.text.trim().isNotEmpty)
              Expanded(child: _searchResults(_searchController.text.trim())),
          ],
        ),
      ),
    );
  }

  Widget _searchResults(String query) {
    final results = ref.watch(searchUsersProvider(query));
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (_, i) => _userTile(users[i]),
        );
      },
    );
  }

  Widget _userTile(FriendProfile user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.grey100,
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(user.displayName[0].toUpperCase(),
                  style: AppTypography.s1.copyWith(color: AppColors.grey500))
              : null,
        ),
        title: Text(user.displayName, style: AppTypography.s2),
        subtitle: user.bio != null ? Text(user.bio!, style: AppTypography.b5) : null,
        trailing: user.friendStatus == 'pending'
            ? Text('Pending', style: AppTypography.c1.copyWith(color: AppColors.warning))
            : TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserSearchScreen(userId: user.id),
                  ),
                ),
                child: const Text('View', style: AppTypography.buttonMedium),
              ),
      ),
    );
  }
}
