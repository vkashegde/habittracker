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
    final last30 = habitService.completionsInLastDays(habit, 30);

    String? milestoneText;
    if (streak >= 100) {
      milestoneText = '🔥 Legend: 100+ day streak!';
    } else if (streak >= 30) {
      milestoneText = '🔥 Amazing: 30-day streak!';
    } else if (streak >= 7) {
      milestoneText = '🔥 Nice: 7-day streak!';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (streak > 0)
                const Icon(
                  Icons.local_fire_department,
                  size: 18,
                  color: Colors.orange,
                ),
              if (streak > 0) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  habit.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text('Current streak: $streak day(s)'),
          Text('Completed on $last7 of last 7 days'),
          Text('Completed on $last30 of last 30 days'),
          if (milestoneText != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                milestoneText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 4),
          _MiniCalendarStrip(habit: habit),
        ],
      ),
    );
  }
}

/// Simple 4-week calendar strip (last 28 days) showing completion as dots.
class _MiniCalendarStrip extends StatelessWidget {
  const _MiniCalendarStrip({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 27));

    final days = List<DateTime>.generate(
      28,
      (i) => DateTime(start.year, start.month, start.day + i),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last 4 weeks',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: days.map((day) {
            final done = habitService.isCompletedOnDate(habit, day);
            final isToday = day.year == today.year &&
                day.month == today.month &&
                day.day == today.day;

            return Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? Colors.green : Colors.grey.shade300,
                border: isToday
                    ? Border.all(
                        color: Colors.blue,
                        width: 1,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

