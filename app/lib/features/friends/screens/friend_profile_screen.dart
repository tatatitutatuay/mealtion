import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../providers/profile_provider.dart';
import '../models/profile_data.dart';
import '../../home/providers/gallery_provider.dart';
import '../../home/widgets/meal_detail_sheet.dart';

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
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.grey100,
            backgroundImage: data.photoUrl != null ? NetworkImage(data.photoUrl!) : null,
            child: data.photoUrl == null
                ? Text(data.displayName[0].toUpperCase(), style: AppTypography.h5)
                : null,
          ),
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
          Expanded(child: _statBox('Meals', '${data.totalMeals}')),
          const SizedBox(width: 10),
          Expanded(child: _statBox('Friends', '${data.friendsCount}')),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: AppSpacing.cardBorder,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.s1.copyWith(
              color: AppColors.textPrimary, fontSize: 18)),
          Text(label, style: AppTypography.b5.copyWith(
              color: AppColors.textPrimary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _monthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 8),
      child: Row(
        children: [
          _circleButton(Icons.chevron_left, _prevMonth),
          const SizedBox(width: 5),
          _pillButton(DateFormat('MMMM yyyy').format(_currentMonth)),
          const SizedBox(width: 5),
          _circleButton(Icons.chevron_right, _nextMonth),
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

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 23,
        height: 23,
        decoration: const BoxDecoration(
          border: AppSpacing.cardBorder,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _pillButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: AppSpacing.cardBorder,
        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
      ),
      child: Text(label, style: AppTypography.b5.copyWith(
          color: AppColors.textPrimary, fontSize: 12)),
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
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => MealDetailSheet.show(context, items[i].mealId, canEdit: false),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
          child: Image.network(items[i].thumbnailUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _timelineView(List<GalleryItem> items) {
    final grouped = <String, List<GalleryItem>>{};
    for (final item in items) {
      final key = DateFormat('d MMM').format(item.date);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 16),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final entry = grouped.entries.elementAt(i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Text(entry.key.split(' ').first,
                        style: AppTypography.b5.copyWith(
                            color: AppColors.textPrimary, fontSize: 12)),
                    Text(entry.key.split(' ').last,
                        style: AppTypography.b5.copyWith(
                            color: AppColors.textPrimary, fontSize: 12)),
                  ],
                ),
              ),
              Container(width: 0.5, margin: const EdgeInsets.only(right: 8), color: AppColors.border),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.value.map((item) => _timelineCard(item)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timelineCard(GalleryItem item) {
    return GestureDetector(
      onTap: () => MealDetailSheet.show(context, item.mealId, canEdit: false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPhoto),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusPhoto),
                bottomLeft: Radius.circular(AppSpacing.radiusPhoto),
              ),
              child: Container(
                width: 90,
                height: 90,
                color: AppColors.photoPlaceholder,
                child: Image.network(item.thumbnailUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.foods.join(', '),
                        style: AppTypography.s2.copyWith(
                            color: AppColors.textPrimary, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (item.restaurantName != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item.restaurantName}${item.branchName != null ? ' (${item.branchName})' : ''}',
                              style: AppTypography.b5.copyWith(
                                  color: AppColors.textSecondary, fontSize: 12),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
