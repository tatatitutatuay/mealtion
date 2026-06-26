import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _photoUrl;
  File? _pickedPhoto;
  bool _photoRemoved = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(myProfileProvider).valueOrNull;
    final auth = ref.read(authProvider);
    _displayNameController = TextEditingController(text: profile?.displayName ?? auth?.displayName ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? auth?.username ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _photoUrl = (profile?.photoUrl ?? auth?.photoUrl ?? '').isNotEmpty
        ? (profile?.photoUrl ?? auth?.photoUrl)
        : null;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedPhoto = File(picked.path));
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedPhoto = File(picked.path));
    }
  }

  Future<void> _save() async {
    final userId = ref.read(authProvider)?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      String? newPhotoUrl;

      if (_pickedPhoto != null) {
        final ext = _pickedPhoto!.path.split('.').last;
        final storagePath = '$userId/avatar.$ext';
        try {
          await supabase.storage.from('avatars').remove([storagePath]);
        } catch (_) {}
        await supabase.storage.from('avatars').upload(storagePath, _pickedPhoto!);
        newPhotoUrl = supabase.storage.from('avatars').getPublicUrl(storagePath);
      }

      await supabase.from('profiles').update({
        'display_name': _displayNameController.text.trim(),
        'username': _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        if (newPhotoUrl != null) 'photo_url': newPhotoUrl,
        if (_photoRemoved && newPhotoUrl == null) 'photo_url': '',
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
            Center(
              child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_outlined),
                          title: const Text('Choose from Gallery'),
                          onTap: () { Navigator.pop(ctx); _pickPhoto(); },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt_outlined),
                          title: const Text('Take Photo'),
                          onTap: () { Navigator.pop(ctx); _takePhoto(); },
                        ),
                        if (_pickedPhoto != null || _photoUrl != null)
                          ListTile(
                            leading: const Icon(Icons.delete_outline, color: AppColors.error),
                            title: const Text('Remove Photo'),
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _pickedPhoto = null;
                                _photoUrl = null;
                                _photoRemoved = true;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.grey100,
                  backgroundImage: _pickedPhoto != null
                      ? FileImage(_pickedPhoto!)
                      : (_photoUrl != null ? NetworkImage(_photoUrl!) : null),
                  child: (_pickedPhoto == null && _photoUrl == null)
                      ? const Icon(Icons.camera_alt, color: AppColors.grey500)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Display Name', style: AppTypography.s2),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController,
              maxLength: 30,
              decoration: const InputDecoration(hintText: 'Your display name'),
            ),
            const SizedBox(height: 16),
            const Text('Username', style: AppTypography.s2),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              maxLength: 20,
              decoration: const InputDecoration(hintText: 'your_username', prefixText: '@'),
            ),
            const SizedBox(height: 16),
            const Text('Bio', style: AppTypography.s2),
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
