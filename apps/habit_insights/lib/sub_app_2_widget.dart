import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Simple insights/summary widget for the habit data.
///
/// This lives in the `habit_insights_app` package but is also reused by
/// `main_app` to demonstrate sharing UI across apps.
class HabitInsightsWidget extends StatelessWidget {
  const HabitInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = habitService.getAllHabits();

    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Habit Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (habits.isEmpty)
              const Text('No habits to analyse.'),
            for (final habit in habits)
              _HabitInsightRow(habit: habit),
          ],
        ),
      ),
    );
  }
}

class _HabitInsightRow extends StatelessWidget {
  const _HabitInsightRow({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final streak = habitService.streakForHabit(habit);
    final last7 = habitService.completionsInLastDays(habit, 7);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Current streak: $streak day(s)',
          ),
          Text(
            'Completed on $last7 of last 7 days',
          ),
        ],
      ),
    );
  }
}

