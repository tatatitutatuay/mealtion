import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../../../core/supabase/supabase_client.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  String _currency = 'THB';
  final _thresholdLowController = TextEditingController(text: '10');
  final _thresholdHighController = TextEditingController(text: '50');
  bool _isSaving = false;

  static const _currencies = ['THB', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'SGD'];

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _thresholdLowController.dispose();
    _thresholdHighController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _progressBar(),
            Expanded(child: _stepContent()),
            _navButtons(),
          ],
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.layoutMargin),
      child: Row(
        children: List.generate(
          5,
          (i) => Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= _step ? AppColors.primary : AppColors.grey100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepContent() {
    return switch (_step) {
      0 => _profileIdentityStep(),
      1 => _profileInfoStep(),
      2 => _currencyStep(),
      3 => _thresholdsStep(),
      4 => _permissionsStep(),
      _ => const SizedBox(),
    };
  }

  Widget _profileIdentityStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile Identity', style: AppTypography.h5),
          const SizedBox(height: 24),
          const Text('Display Name', style: AppTypography.b4),
          const SizedBox(height: 8),
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Your name',
            ),
          ),
          const SizedBox(height: 16),
          const Text('Username', style: AppTypography.b4),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '@username',
              prefixText: '@',
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile Information', style: AppTypography.h5),
          const SizedBox(height: 24),
          const Text('Bio', style: AppTypography.b4),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 3,
            maxLength: 150,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Tell us about yourself',
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Currency', style: AppTypography.h5),
          const SizedBox(height: 24),
          const Text('Select your primary currency', style: AppTypography.b4),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currencies.map((c) {
              final selected = c == _currency;
              return GestureDetector(
                onTap: () => setState(() => _currency = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.grey50,
                    border: Border.all(color: selected ? AppColors.primary : AppColors.grey100),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                  child: Text(
                    c,
                    style: AppTypography.b3.copyWith(
                      color: selected ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _thresholdsStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price Thresholds', style: AppTypography.h5),
          const SizedBox(height: 24),
          const Text('Meals below the low threshold are Affordable. Above the high threshold are Expensive.', style: AppTypography.b4),
          const SizedBox(height: 16),
          const Text('Affordable below', style: AppTypography.b4),
          const SizedBox(height: 8),
          TextField(
            controller: _thresholdLowController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixText: _currency,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Expensive above', style: AppTypography.b4),
          const SizedBox(height: 8),
          TextField(
            controller: _thresholdHighController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixText: _currency,
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionsStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.layoutMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Permissions', style: AppTypography.h5),
          const SizedBox(height: 24),
          _permissionItem(Icons.photo_library_outlined, 'Photo Library', 'Access your photos to add meal pictures'),
          _permissionItem(Icons.camera_alt_outlined, 'Camera', 'Take photos of your meals'),
          _permissionItem(Icons.notifications_outlined, 'Notifications', 'Get notified about friend activity'),
          const SizedBox(height: 32),
          Text(
            'You can change these later in Settings.',
            style: AppTypography.b5.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _permissionItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.b3),
                Text(subtitle, style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.layoutMargin),
      child: Row(
        children: [
          if (_step > 0)
            TextButton(
              onPressed: () => setState(() => _step--),
              child: const Text('Back'),
            ),
          const Spacer(),
          if (_step < 4)
            FilledButton(
              onPressed: _next,
              child: const Text('Next'),
            )
          else
            FilledButton(
              onPressed: _isSaving ? null : _finish,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                  : const Text('Get Started'),
            ),
        ],
      ),
    );
  }

  void _next() {
    if (_step == 0 && _displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a display name')));
      return;
    }
    setState(() => _step++);
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser!.id;
      final low = double.tryParse(_thresholdLowController.text) ?? 10;
      final high = double.tryParse(_thresholdHighController.text) ?? 50;

      await supabase.from('profiles').update({
        'display_name': _displayNameController.text.trim(),
        'username': _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'primary_currency': _currency,
        'price_threshold_low': low,
        'price_threshold_high': high,
        'onboarding_completed': true,
      }).eq('id', userId);

      // Refresh auth state — triggers router redirect
      ref.read(authProvider.notifier).state = ref.read(authProvider)!.copyWith(
            displayName: _displayNameController.text.trim(),
            username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
            onboardingCompleted: true,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
