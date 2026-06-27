import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import 'package:mealtion/core/widgets/image_picker_sheet.dart';
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
  Uint8List? _pickedPhotoBytes;
  bool _photoRemoved = false;
  String? _coverUrl;
  File? _pickedCover;
  Uint8List? _pickedCoverBytes;
  bool _coverRemoved = false;
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
    _coverUrl = profile?.coverUrl;
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
      final bytes = kIsWeb ? await picked.readAsBytes() : null;
      setState(() {
        _pickedPhoto = kIsWeb ? null : File(picked.path);
        _pickedPhotoBytes = bytes;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      final bytes = kIsWeb ? await picked.readAsBytes() : null;
      setState(() {
        _pickedPhoto = kIsWeb ? null : File(picked.path);
        _pickedPhotoBytes = bytes;
      });
    }
  }

  Future<void> _pickCover() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = kIsWeb ? await picked.readAsBytes() : null;
      setState(() {
        _pickedCover = kIsWeb ? null : File(picked.path);
        _pickedCoverBytes = bytes;
      });
    }
  }

  Future<void> _takeCover() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      final bytes = kIsWeb ? await picked.readAsBytes() : null;
      setState(() {
        _pickedCover = kIsWeb ? null : File(picked.path);
        _pickedCoverBytes = bytes;
      });
    }
  }

  Future<void> _save() async {
    final userId = ref.read(authProvider)?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      String? newPhotoUrl;
      String? newCoverUrl;

      if (_pickedPhoto != null || _pickedPhotoBytes != null) {
        final ext = _pickedPhoto?.path.split('.').last ?? 'jpg';
        final storagePath = '$userId/avatar.$ext';
        try {
          await supabase.storage.from('avatars').remove([storagePath]);
        } catch (e) {
          debugPrint('Failed to remove old avatar: $e');
        }
        if (_pickedPhotoBytes != null) {
          await supabase.storage.from('avatars').uploadBinary(storagePath, _pickedPhotoBytes!);
        } else {
          await supabase.storage.from('avatars').upload(storagePath, _pickedPhoto!);
        }
        newPhotoUrl = supabase.storage.from('avatars').getPublicUrl(storagePath);
      }

      if (_pickedCover != null || _pickedCoverBytes != null) {
        final ext = _pickedCover?.path.split('.').last ?? 'jpg';
        final storagePath = '$userId/cover.$ext';
        try {
          await supabase.storage.from('covers').remove([storagePath]);
        } catch (e) {
          debugPrint('Failed to remove old cover: $e');
        }
        if (_pickedCoverBytes != null) {
          await supabase.storage.from('covers').uploadBinary(storagePath, _pickedCoverBytes!);
        } else {
          await supabase.storage.from('covers').upload(storagePath, _pickedCover!);
        }
        newCoverUrl = supabase.storage.from('covers').getPublicUrl(storagePath);
      }

      await supabase.from('profiles').upsert({
        'id': userId,
        'display_name': _displayNameController.text.trim(),
        'username': _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        if (newPhotoUrl != null) 'photo_url': newPhotoUrl,
        if (_photoRemoved && newPhotoUrl == null) 'photo_url': '',
        if (newCoverUrl != null) 'cover_url': newCoverUrl,
        if (_coverRemoved && newCoverUrl == null) 'cover_url': '',
      }, onConflict: 'id');

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover + Avatar (overlapping, like profile page)
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover photo
                GestureDetector(
                  onTap: () => ImagePickerSheet.show(
                    context: context,
                    galleryLabel: 'Choose Cover from Gallery',
                    cameraLabel: 'Take Cover Photo',
                    removeLabel: 'Remove Cover',
                    canRemove: _pickedCover != null || _pickedCoverBytes != null || _coverUrl != null,
                    onGallery: _pickCover,
                    onCamera: _takeCover,
                    onRemove: () => setState(() {
                      _pickedCover = null;
                      _pickedCoverBytes = null;
                      _coverUrl = null;
                      _coverRemoved = true;
                    }),
                  ),
                  child: Container(
                    height: 222,
                    width: double.infinity,
                    color: AppColors.grey100,
                    child: (_pickedCoverBytes != null
                        ? Image.memory(_pickedCoverBytes!, fit: BoxFit.cover)
                        : (_pickedCover != null
                            ? Image.file(_pickedCover!, fit: BoxFit.cover)
                            : (_coverUrl != null
                                ? Image.network(_coverUrl!, fit: BoxFit.cover)
                                : const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.grey500),
                                        SizedBox(height: 4),
                                        Text('Add Cover Photo', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                                      ],
                                    ),
                                  )))),
                  ),
                ),
                // Avatar centered, bottom half overflows the cover
                Positioned(
                  top: 158,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => ImagePickerSheet.show(
                        context: context,
                        galleryLabel: 'Choose from Gallery',
                        cameraLabel: 'Take Photo',
                        removeLabel: 'Remove Photo',
                        canRemove: _pickedPhoto != null || _pickedPhotoBytes != null || _photoUrl != null,
                        onGallery: _pickPhoto,
                        onCamera: _takePhoto,
                        onRemove: () => setState(() {
                          _pickedPhoto = null;
                          _pickedPhotoBytes = null;
                          _photoUrl = null;
                          _photoRemoved = true;
                        }),
                      ),
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey100,
                          border: Border.all(color: AppColors.white, width: 3),
                          image: _pickedPhotoBytes != null
                              ? DecorationImage(image: MemoryImage(_pickedPhotoBytes!), fit: BoxFit.cover)
                              : (_pickedPhoto != null
                                  ? DecorationImage(image: FileImage(_pickedPhoto!), fit: BoxFit.cover)
                                  : (_photoUrl != null
                                      ? DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.cover)
                                      : null)),
                        ),
                        child: (_pickedPhoto == null && _pickedPhotoBytes == null && _photoUrl == null)
                            ? const Center(child: Icon(Icons.camera_alt, size: 32, color: AppColors.grey500))
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 74),
            // Form fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          ],
        ),
      ),
    );
  }
}
