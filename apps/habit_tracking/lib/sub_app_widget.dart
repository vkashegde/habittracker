import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Quick daily check-in widget for habits.
///
/// This lives in the `habit_checkin_app` package but is also reused by
/// `main_app` to demonstrate sharing UI across apps.
class HabitCheckinWidget extends StatefulWidget {
  const HabitCheckinWidget({super.key});

  @override
  State<HabitCheckinWidget> createState() => _HabitCheckinWidgetState();
}

class _HabitCheckinWidgetState extends State<HabitCheckinWidget> {
  @override
  Widget build(BuildContext context) {
    final todayHabits = habitService.getTodayHabits();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Habits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (todayHabits.isEmpty)
              const Text('No habits configured.'),
            for (final status in todayHabits)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(status.habit.name),
                subtitle: Text(status.habit.description),
                value: status.completed,
                onChanged: (_) {
                  setState(() {
                    habitService.toggleHabitForToday(status.habit);
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

