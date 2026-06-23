import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../../friends/providers/profile_provider.dart';
import '../../../core/supabase/supabase_client.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(myProfileProvider).valueOrNull;
    _displayNameController = TextEditingController(text: profile?.displayName ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final userId = ref.read(authProvider)?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.from('profiles').update({
        'display_name': _displayNameController.text.trim(),
        'username': _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      }).eq('id', userId);

      ref.invalidate(myProfileProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.layoutMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display Name', style: AppTypography.s2),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController,
              maxLength: 30,
              decoration: const InputDecoration(hintText: 'Your display name'),
            ),
            const SizedBox(height: 16),
            Text('Username', style: AppTypography.s2),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              maxLength: 20,
              decoration: const InputDecoration(hintText: 'your_username', prefixText: '@'),
            ),
            const SizedBox(height: 16),
            Text('Bio', style: AppTypography.s2),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLength: 150,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Tell something about yourself'),
            ),
          ],
        ),
      ),
    );
  }
}
