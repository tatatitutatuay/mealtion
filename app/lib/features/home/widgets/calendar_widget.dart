import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealtion/core/theme/colors.dart';
import 'package:mealtion/core/theme/spacing.dart';
import 'package:mealtion/core/theme/typography.dart';
import '../models/home_data.dart';
import '../providers/meal_detail_provider.dart';
import 'meal_detail_sheet.dart';

enum CalendarFilterMode { health, heaviness, feeling, price }

const _filterLabels = {
  CalendarFilterMode.health: 'Health',
  CalendarFilterMode.heaviness: 'Heaviness',
  CalendarFilterMode.feeling: 'Feeling',
  CalendarFilterMode.price: 'Price',
};

class CalendarWidget extends ConsumerStatefulWidget {
  final List<DateTime> mealDates;
  final List<CalendarMealInfo> mealInfos;

  const CalendarWidget({super.key, required this.mealDates, required this.mealInfos});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  late DateTime _currentMonth;
  CalendarFilterMode _filterMode = CalendarFilterMode.health;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _prevMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1));
  void _nextMonth() => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1));

  void _cycleFilter() {
    setState(() {
      const modes = CalendarFilterMode.values;
      _filterMode = modes[(modes.indexOf(_filterMode) + 1) % modes.length];
    });
  }

  void _openMealsForDate(DateTime date) async {
    final meals = await ref.read(mealsByDateProvider(date).future);
    if (!mounted) return;
    if (meals.isEmpty) return;
    MealDetailSheet.showMultiple(context, meals.map((m) => m.id).toList());
  }

  Color _dotColorForDate(DateTime date) {
    final infos = widget.mealInfos.where((m) =>
        m.date.year == date.year && m.date.month == date.month && m.date.day == date.day).toList();
    if (infos.isEmpty) return AppColors.primary;

    switch (_filterMode) {
      case CalendarFilterMode.health:
        return AppColors.primary;
      case CalendarFilterMode.heaviness:
        const order = {'heavy': 3, 'satisfying': 2, 'light': 1};
        final heaviest = infos.where((m) => m.heaviness != null).fold<CalendarMealInfo?>(null, (a, b) {
          if (a == null) return b;
          final av = order[a.heaviness] ?? 0;
          final bv = order[b.heaviness] ?? 0;
          return bv > av ? b : a;
        });
        return switch (heaviest?.heaviness) {
          'light' => const Color(0xFF4CAF50),
          'satisfying' => const Color(0xFFFF9800),
          'heavy' => const Color(0xFFF44336),
          _ => AppColors.primary,
        };
      case CalendarFilterMode.feeling:
        const order = {'dislike': 3, 'neutral': 2, 'like': 1};
        final worst = infos.where((m) => m.feeling != null).fold<CalendarMealInfo?>(null, (a, b) {
          if (a == null) return b;
          final av = order[a.feeling] ?? 0;
          final bv = order[b.feeling] ?? 0;
          return bv > av ? b : a;
        });
        return switch (worst?.feeling) {
          'like' => const Color(0xFF4CAF50),
          'neutral' => AppColors.grey500,
          'dislike' => const Color(0xFFF44336),
          _ => AppColors.primary,
        };
      case CalendarFilterMode.price:
        final avgPrice = infos.where((m) => m.price != null).map((m) => m.price!).toList();
        if (avgPrice.isEmpty) return AppColors.primary;
        final avg = avgPrice.reduce((a, b) => a + b) / avgPrice.length;
        if (avg < 100) return const Color(0xFF4CAF50);
        if (avg < 500) return const Color(0xFFFF9800);
        return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    const dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.layoutMargin),
      child: Container(
        decoration: BoxDecoration(
          border: AppSpacing.cardBorder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header row: month nav + filter pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  // Month nav group
                  Row(
                    children: [
                      _circleButton(Icons.chevron_left, _prevMonth),
                      const SizedBox(width: 5),
                      _pillButton(DateFormat('MMMM yyyy').format(_currentMonth)),
                      const SizedBox(width: 5),
                      _circleButton(Icons.chevron_right, _nextMonth),
                    ],
                  ),
                  const Spacer(),
                  // Filter pill
                  GestureDetector(
                    onTap: _cycleFilter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: AppSpacing.cardBorder,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tune, size: 11, color: AppColors.textPrimary),
                          const SizedBox(width: 5),
                          Text(_filterLabels[_filterMode]!,
                              style: AppTypography.b5.copyWith(
                                  color: AppColors.textPrimary, fontSize: 12)),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textPrimary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Divider(height: 0, thickness: 0.5, color: AppColors.border),
            const SizedBox(height: 15),
            // Day headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: dayHeaders.map((d) => Expanded(
                  child: Center(
                    child: Text(d,
                        style: AppTypography.b5.copyWith(
                            color: AppColors.textPrimary, fontSize: 12)),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Date grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.8,
                ),
                itemCount: firstWeekday + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < firstWeekday) return const SizedBox.shrink();
                  final day = index - firstWeekday + 1;
                  final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                  final hasMeal = widget.mealDates.any((d) =>
                      d.year == date.year && d.month == date.month && d.day == date.day);
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final dotColor = _dotColorForDate(date);

                  return GestureDetector(
                    onTap: hasMeal ? () => _openMealsForDate(date) : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary : null,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: AppTypography.b5.copyWith(
                              color: isToday ? AppColors.white : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: isToday ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (hasMeal) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
      child: Text(label,
          style: AppTypography.b5.copyWith(color: AppColors.textPrimary, fontSize: 12)),
    );
  }
}
