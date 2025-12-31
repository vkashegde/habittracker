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
    final total = todayHabits.length;
    final completed = todayHabits.where((h) => h.completed).length;
    final completionRatio = total == 0 ? 0.0 : completed / total;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1120), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.45),
            blurRadius: 28,
            spreadRadius: -12,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF6366F1)]),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22D3EE).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: -6,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.checklist_rounded, color: Colors.black, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Habits',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todayHabits.isEmpty
                            ? 'Nothing queued – add your first glow-up habit.'
                            : 'Check off habits and track your streak in one place.',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.25),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$completed / $total done',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 80,
                          height: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: completionRatio.clamp(0, 1),
                              backgroundColor: Colors.white.withOpacity(0.12),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22D3EE)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (todayHabits.isEmpty) const Text('No habits configured.'),
            for (final status in todayHabits)
              switch (status.habit.type) {
                HabitType.boolean => _BooleanHabitTile(
                  status: status,
                  onToggle: () {
                    setState(() {
                      habitService.toggleHabitForToday(status.habit);
                    });
                  },
                ),
                HabitType.count || HabitType.duration => _AmountHabitTile(
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
  const _AmountHabitTile({required this.status, required this.onChanged});

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

    final completed = target != null && target > 0 ? amount >= target : amount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: completed
            ? const Color(0xFF22C55E).withOpacity(0.14)
            : Colors.white.withOpacity(0.02),
        border: Border.all(
          color: completed ? const Color(0xFF22C55E) : Colors.white.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF6366F1)]),
            ),
            child: Icon(isCount ? Icons.filter_9_plus : Icons.timer, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  habit.description,
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: target != null && target > 0
                              ? (amount / target).clamp(0, 1)
                              : (amount > 0 ? 1.0 : 0.0),
                          backgroundColor: Colors.white.withOpacity(0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22D3EE)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      progressText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF22D3EE),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: amount > 0
                      ? () {
                          final next = (amount - step).clamp(0, 1000000);
                          onChanged(next);
                        }
                      : null,
                ),
                Text('$amount', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    final next = (amount + step).clamp(0, 1000000);
                    onChanged(next);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern, tappable tile for yes/no style habits.
class _BooleanHabitTile extends StatelessWidget {
  const _BooleanHabitTile({required this.status, required this.onToggle});

  final TodayHabitStatus status;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final habit = status.habit;
    final completed = status.completed;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: completed
              ? const Color(0xFF22C55E).withOpacity(0.16)
              : Colors.white.withOpacity(0.02),
          border: Border.all(
            color: completed ? const Color(0xFF22C55E) : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: completed
                    ? const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)])
                    : const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF6366F1)]),
              ),
              child: Icon(
                completed ? Icons.check_rounded : Icons.radio_button_unchecked,
                size: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habit.description,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completed ? 'Nice, this one is done for today!' : 'Tap to mark as done.',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: completed,
              activeThumbColor: const Color(0xFF22C55E),
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}
