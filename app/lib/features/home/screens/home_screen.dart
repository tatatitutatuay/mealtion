import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtion/core/theme/spacing.dart';
import '../providers/home_provider.dart';
import '../widgets/greeting_bar.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/emotion_filters.dart';
import '../widgets/monthly_snapshot.dart';
import '../widgets/recap_cards.dart';
import '../widgets/recent_entries.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);

    return Scaffold(
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingBar(
                displayName: data.displayName,
                photoUrl: data.photoUrl,
              ),
              const SizedBox(height: 24),
              CalendarWidget(mealDates: data.mealDatesThisMonth),
              const SizedBox(height: 16),
              const EmotionFilters(),
              const SizedBox(height: 24),
              MonthlySnapshot(
                totalMeals: data.totalMealsThisMonth,
                totalFoods: data.totalFoodsThisMonth,
                totalRestaurants: data.totalRestaurantsThisMonth,
                totalSpent: data.totalSpentThisMonth,
              ),
              const SizedBox(height: 24),
              const RecapCards(),
              const SizedBox(height: 24),
              RecentEntries(meals: data.recentMeals),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
