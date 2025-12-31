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
              switch (status.habit.type) {
                HabitType.boolean => CheckboxListTile(
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
                HabitType.count ||
                HabitType.duration =>
                  _AmountHabitTile(
                    status: status,
                    onChanged: (newAmount) {
                      setState(() {
                        habitService.setAmountForToday(status.habit, newAmount);
                      });
                    },
                  ),
              },
          ],
        ),
      ),
    );
  }
}

/// Tile for counter/timer-style habits (e.g. water glasses, meditation minutes).
class _AmountHabitTile extends StatelessWidget {
  const _AmountHabitTile({
    required this.status,
    required this.onChanged,
  });

  final TodayHabitStatus status;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final habit = status.habit;
    final target = habit.dailyTarget;
    final amount = status.amount;

    final isCount = habit.type == HabitType.count;
    final step = isCount ? 1 : 5;

    String progressText;
    if (target != null && target > 0) {
      progressText = '$amount / $target ${isCount ? 'count' : 'min'}';
    } else {
      progressText = '$amount ${isCount ? 'count' : 'min'}';
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(habit.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habit.description),
          const SizedBox(height: 4),
          Text(
            progressText,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: amount > 0
                ? () {
                    final next = (amount - step).clamp(0, 1000000);
                    onChanged(next);
                  }
                : null,
          ),
          Text('$amount'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final next = (amount + step).clamp(0, 1000000);
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

