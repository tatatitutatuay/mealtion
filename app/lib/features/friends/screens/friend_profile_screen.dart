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
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => SingleChildScrollView(
          child: Column(
            children: [
              _header(data),
              const SizedBox(height: 16),
              _statsRow(data),
              const SizedBox(height: 16),
              _monthNav(),
              const Divider(height: 1),
              gallery.when(
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (err, _) => SizedBox(height: 200, child: Center(child: Text('Error: $err'))),
                data: (items) {
                  if (items.isEmpty) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Text('No meals in ${DateFormat('MMMM yyyy').format(_currentMonth)}',
                            style: AppTypography.b3.copyWith(color: AppColors.textSecondary)),
                      ),
                    );
                  }
                  return _isGridView ? _gridView(items) : _timelineView(items);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(ProfileData data) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.layoutMargin),
      child: Row(
        children: [
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
                Text(data.displayName, style: AppTypography.s1),
                if (data.username != null)
                  Text('@${data.username}', style: AppTypography.b4.copyWith(color: AppColors.textSecondary)),
                if (data.bio != null && data.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(data.bio!, style: AppTypography.b5, maxLines: 2, overflow: TextOverflow.ellipsis),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Meals', data.totalMeals),
          _stat('Friends', data.friendsCount),
        ],
      ),
    );
  }

  Widget _stat(String label, int count) {
    return Column(
      children: [
        Text('$count', style: AppTypography.s1),
        Text(label, style: AppTypography.b5.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _monthNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth, visualDensity: VisualDensity.compact),
          Text(DateFormat('MMMM yyyy').format(_currentMonth), style: AppTypography.s2),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth, visualDensity: VisualDensity.compact),
          const Spacer(),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
    );
  }

  Widget _gridView(List<GalleryItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
          borderRadius: BorderRadius.circular(8),
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin, vertical: 16),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final entry = grouped.entries.elementAt(i);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(entry.key, style: AppTypography.s2.copyWith(color: AppColors.textSecondary)),
            ),
            ...entry.value.map((item) => _timelineCard(item)),
            const SizedBox(height: 16),
          ],
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusXs),
                bottomLeft: Radius.circular(AppSpacing.radiusXs),
              ),
              child: Image.network(item.thumbnailUrl, width: 90, height: 90, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.foods.join(', '), style: AppTypography.b4, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (item.restaurantName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${item.restaurantName}${item.branchName != null ? ' • ${item.branchName}' : ''}',
                        style: AppTypography.b5.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
