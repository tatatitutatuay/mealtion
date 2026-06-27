import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/friends_providers.dart';
import '../providers/friend_actions.dart';

class UserSearchScreen extends ConsumerWidget {
  final String userId;

  const UserSearchScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Connect')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.layoutMargin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.grey100,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null
                        ? Text(user.displayName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 32, color: AppColors.grey500))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(user.displayName, style: AppTypography.h5),
                  if (user.username != null) ...[
                    const SizedBox(height: 4),
                    Text('@${user.username}', style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                  ],
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(user.bio!, style: AppTypography.b3, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref.read(friendActionsProvider).sendRequest(userId);
                          ref.invalidate(sentRequestsProvider);
                          // Invalidate all searchUsersProvider instances so ConnectScreen refreshes
                          ref.invalidate(searchUsersProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Friend request sent!')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Send Request'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
