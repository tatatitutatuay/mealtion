import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../../../core/supabase/supabase_client.dart';
import '../providers/notifications_provider.dart';
import '../../home/widgets/meal_detail_sheet.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none, size: 48, color: AppColors.grey500),
                  const SizedBox(height: 12),
                  Text('No notifications yet', style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) => _notificationTile(context, ref, items[i]),
          );
        },
      ),
    );
  }

  Widget _notificationTile(BuildContext context, WidgetRef ref, NotificationItem item) {
    final iconData = switch (item.type) {
      'friend_request' => Icons.person_add_outlined,
      'friend_accepted' => Icons.people_outlined,
      'like' => Icons.favorite,
      'comment' => Icons.chat_bubble_outline,
      _ => Icons.notifications,
    };
    final iconColor = switch (item.type) {
      'friend_request' => AppColors.primary,
      'friend_accepted' => AppColors.success,
      'like' => AppColors.error,
      'comment' => AppColors.warning,
      _ => AppColors.grey500,
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.15),
        child: Icon(iconData, color: iconColor, size: 20),
      ),
      title: RichText(
        text: TextSpan(
          style: AppTypography.b3.copyWith(color: AppColors.textPrimary),
          children: [
            if (item.actorName != null)
              TextSpan(text: '${item.actorName} ', style: AppTypography.b3.copyWith(fontWeight: FontWeight.w600)),
            TextSpan(text: item.label),
            if (item.groupCount > 1) TextSpan(text: ' (+${item.groupCount - 1})'),
          ],
        ),
      ),
      subtitle: Text(DateFormat('d MMM, HH:mm').format(item.createdAt), style: AppTypography.c3),
      trailing: item.isRead ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
      onTap: () => _handleTap(context, ref, item),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, NotificationItem item) async {
    // Mark as read
    final supabase = ref.read(supabaseProvider);
    await supabase.from('notifications').update({'is_read': true}).eq('id', item.id);
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);

    // Navigate based on type
    if (item.mealId != null && context.mounted) {
      MealDetailSheet.show(context, item.mealId!, canEdit: false);
    }
  }
}
