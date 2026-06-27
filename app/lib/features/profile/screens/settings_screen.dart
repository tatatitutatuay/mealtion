import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/push/push_notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/profile_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _currency = 'THB';
  String _pricePrivacy = 'actual';
  bool _notifLikes = true;
  bool _notifComments = true;
  bool _notifFriendRequests = true;
  bool _isDeleting = false;

  static const _currencies = ['THB', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'SGD'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser!.id;
    final row = await supabase
        .from('profiles')
        .select('primary_currency, price_display_privacy, notif_likes, notif_comments, notif_friend_requests')
        .eq('id', userId)
        .maybeSingle();
    if (row != null && mounted) {
      setState(() {
        _currency = row['primary_currency'] as String? ?? 'THB';
        _pricePrivacy = row['price_display_privacy'] as String? ?? 'actual';
        _notifLikes = row['notif_likes'] as bool? ?? true;
        _notifComments = row['notif_comments'] as bool? ?? true;
        _notifFriendRequests = row['notif_friend_requests'] as bool? ?? true;
      });
    }
  }

  void _saveCurrency(String currency) async {
    setState(() => _currency = currency);
    final supabase = ref.read(supabaseProvider);
    await supabase.from('profiles').update({'primary_currency': currency}).eq('id', supabase.auth.currentUser!.id);
    // Update auth state in-place (invalidating authProvider would reset to null)
    final auth = ref.read(authProvider);
    if (auth != null) {
      ref.read(authProvider.notifier).state = auth.copyWith(primaryCurrency: currency);
    }
    ref.invalidate(myProfileProvider);
  }

  void _savePricePrivacy(String privacy) async {
    setState(() => _pricePrivacy = privacy);
    final supabase = ref.read(supabaseProvider);
    await supabase.from('profiles').update({'price_display_privacy': privacy}).eq('id', supabase.auth.currentUser!.id);
    final auth = ref.read(authProvider);
    if (auth != null) {
      ref.read(authProvider.notifier).state = auth.copyWith(priceDisplayPrivacy: privacy);
    }
    ref.invalidate(myProfileProvider);
  }

  void _saveNotifPref(String column, bool value) async {
    final supabase = ref.read(supabaseProvider);
    await supabase.from('profiles').update({column: value}).eq('id', supabase.auth.currentUser!.id);
  }

  void _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This will permanently delete your account and all data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final supabase = ref.read(supabaseProvider);
      await ref.read(pushNotificationProvider).unregisterToken();
      // Delete profile row (cascades to all user data)
      await supabase.from('profiles').delete().eq('id', supabase.auth.currentUser!.id);
      await supabase.auth.signOut();
      if (mounted) context.go('/auth/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _section('Currency'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currencies.map((c) {
                final selected = c == _currency;
                return GestureDetector(
                  onTap: () => _saveCurrency(c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.grey50,
                      border: Border.all(color: selected ? AppColors.primary : AppColors.grey100),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Text(c, style: AppTypography.b3.copyWith(color: selected ? AppColors.white : AppColors.textPrimary)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _section('Price Display Privacy'),
          RadioGroup<String>(
            groupValue: _pricePrivacy,
            onChanged: (v) => _savePricePrivacy(v!),
            child: const Column(
              children: [
                RadioListTile<String>(
                  value: 'actual',
                  title: Text('Show actual price'),
                ),
                RadioListTile<String>(
                  value: 'level',
                  title: Text('Show price level only'),
                ),
                RadioListTile<String>(
                  value: 'hidden',
                  title: Text('Hide price'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _section('Notifications'),
          SwitchListTile(
            value: _notifLikes,
            onChanged: (v) {
              setState(() => _notifLikes = v);
              _saveNotifPref('notif_likes', v);
            },
            title: const Text('Likes on my meals'),
          ),
          SwitchListTile(
            value: _notifComments,
            onChanged: (v) {
              setState(() => _notifComments = v);
              _saveNotifPref('notif_comments', v);
            },
            title: const Text('Comments on my meals'),
          ),
          SwitchListTile(
            value: _notifFriendRequests,
            onChanged: (v) {
              setState(() => _notifFriendRequests = v);
              _saveNotifPref('notif_friend_requests', v);
            },
            title: const Text('Friend requests'),
          ),
          const SizedBox(height: 24),
          _section('Account'),
          ListTile(
            leading: _isDeleting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_forever, color: AppColors.error),
            title: Text('Delete Account', style: AppTypography.b3.copyWith(color: AppColors.error)),
            onTap: _isDeleting ? null : _deleteAccount,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text('Log Out', style: AppTypography.b3.copyWith(color: AppColors.error)),
            onTap: () async {
              await ref.read(pushNotificationProvider).unregisterToken();
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/auth/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.layoutMargin, 16, AppSpacing.layoutMargin, 8),
      child: Text(title, style: AppTypography.s2.copyWith(color: AppColors.textSecondary)),
    );
  }
}
