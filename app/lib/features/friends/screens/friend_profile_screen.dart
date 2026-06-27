import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import 'package:mealtion/core/widgets/circle_icon_button.dart';
import 'package:mealtion/core/widgets/meal_grid_tile.dart';
import 'package:mealtion/core/widgets/pill_button.dart';
import 'package:mealtion/core/widgets/stat_box.dart';
import 'package:mealtion/core/widgets/user_avatar.dart';
import '../providers/profile_provider.dart';
import '../models/profile_data.dart';
import '../../home/providers/gallery_provider.dart';
import '../../home/widgets/meal_detail_sheet.dart';
import '../../home/widgets/gallery_timeline.dart';

class FriendProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const FriendProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isGridView = false;

  void _prevMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1));
  void _nextMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1));

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileDataProvider(widget.userId));
    final gallery = ref.watch(userGalleryProvider((userId: widget.userId, month: _currentMonth)));

    return Scaffold(
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => SafeArea(
          child: Column(
            children: [
              _header(data),
              const SizedBox(height: 16),
              _statsRow(data),
              const SizedBox(height: 16),
              _monthNav(),
              const Divider(height: 1, thickness: 0.5, color: AppColors.border),
              Expanded(
                child: gallery.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Text('No meals in ${DateFormat('MMMM yyyy').format(_currentMonth)}',
                            style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                      );
                    }
                    return _isGridView ? _gridView(items) : _timelineView(items);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(ProfileData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 24, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          UserAvatar(photoUrl: data.photoUrl, displayName: data.displayName),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.displayName, style: AppTypography.s1.copyWith(
                    color: AppColors.textPrimary, fontSize: 18)),
                if (data.username != null)
                  Text('@${data.username}', style: AppTypography.b5.copyWith(
                      color: AppColors.textSecondary, fontSize: 12)),
                if (data.bio != null && data.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(data.bio!, style: AppTypography.b5.copyWith(
                      color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(ProfileData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Row(
        children: [
          Expanded(child: StatBox(label: 'Meals', value: '${data.totalMeals}')),
          const SizedBox(width: 10),
          Expanded(child: StatBox(label: 'Friends', value: '${data.friendsCount}')),
        ],
      ),
    );
  }

  Widget _monthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 8),
      child: Row(
        children: [
          CircleIconButton(icon: Icons.chevron_left, onTap: _prevMonth),
          const SizedBox(width: 5),
          PillButton(label: DateFormat('MMMM yyyy').format(_currentMonth)),
          const SizedBox(width: 5),
          CircleIconButton(icon: Icons.chevron_right, onTap: _nextMonth),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: Container(
              height: 23,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: AppSpacing.cardBorder,
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              child: Icon(_isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined,
                  size: 12, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridView(List<GalleryItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => MealGridTile(
        thumbnailUrl: items[i].thumbnailUrl,
        onTap: () => MealDetailSheet.show(context, items[i].mealId, canEdit: false),
      ),
    );
  }

  Widget _timelineView(List<GalleryItem> items) {
    return GalleryTimelineView(
      items: items,
      onTap: (item) => MealDetailSheet.show(context, item.mealId, canEdit: false),
    );
  }
}
