import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Simple insights/summary widget for the habit data.
///
/// This lives in the `habit_insights_app` package but is also reused by
/// `main_app` to demonstrate sharing UI across apps.
class HabitInsightsWidget extends StatelessWidget {
  const HabitInsightsWidget({
    super.key,
    required this.selectedDay,
  });

  /// Calendar day the user is currently looking at.
  ///
  /// By default the main app passes in "today", but the user can select any
  /// other date via the calendar.
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final habits = habitService.getAllHabits();
    final normalizedSelected = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );

    final hasInsightsForDay = habitService.hasInsightsOnDate(normalizedSelected);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1120), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22D3EE).withOpacity(0.45),
            blurRadius: 28,
            spreadRadius: -12,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22D3EE).withOpacity(0.4),
                        blurRadius: 18,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_graph,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Habit Insights',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        'Streaks and stats based on the day you tap in the calendar.',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (habits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No habits to analyse yet.\nStart a habit to see beautiful insights here.',
                  style: TextStyle(fontSize: 13),
                ),
              )
            else if (!hasInsightsForDay)
              _EmptyInsightsForDay(date: normalizedSelected)
            else
              Column(
                children: [
                  for (final habit in habits)
                    _HabitInsightRow(
                      habit: habit,
                      selectedDay: normalizedSelected,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyInsightsForDay extends StatelessWidget {
  const _EmptyInsightsForDay({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.15),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22D3EE).withOpacity(0.35),
                  blurRadius: 24,
                  spreadRadius: -8,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: const Icon(
              Icons.nightlight_round,
              size: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No insights for this day',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ) ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'We couldn\'t find any completed habits on $formatted.\n'
            'Check off a habit on this date to see streaks and trends here.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HabitInsightRow extends StatelessWidget {
  const _HabitInsightRow({
    required this.habit,
    required this.selectedDay,
  });

  final Habit habit;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final streak = habitService.streakForHabit(habit, upTo: selectedDay);
    final last7 = habitService.completionsInLastDays(habit, 7, upTo: selectedDay);
    final last30 = habitService.completionsInLastDays(habit, 30, upTo: selectedDay);
    final theme = Theme.of(context);

    String? milestoneText;
    if (streak >= 100) {
      milestoneText = '🔥 Legend: 100+ day streak!';
    } else if (streak >= 30) {
      milestoneText = '🔥 Amazing: 30-day streak!';
    } else if (streak >= 7) {
      milestoneText = '🔥 Nice: 7-day streak!';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.16),
            blurRadius: 24,
            spreadRadius: -14,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ) ??
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (streak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: const Color(0xFFFFEDD5).withOpacity(0.1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$streak day streak',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (streak > 0) const SizedBox(width: 8),
                        Text(
                          milestoneText ?? 'Stay consistent and build the streak.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Stats up to the selected day',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: 'Last 7 days',
                  value: '$last7 / 7',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricPill(
                  label: 'Last 30 days',
                  value: '$last30 / 30',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _MiniCalendarStrip(
            habit: habit,
            anchorDay: selectedDay,
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple 4-week calendar strip (last 28 days) showing completion as dots.
class _MiniCalendarStrip extends StatelessWidget {
  const _MiniCalendarStrip({
    required this.habit,
    required this.anchorDay,
  });

  final Habit habit;

  /// Center of the mini calendar window; usually the selected day.
  final DateTime anchorDay;

  @override
  Widget build(BuildContext context) {
    final focus = DateTime(anchorDay.year, anchorDay.month, anchorDay.day);
    final start = focus.subtract(const Duration(days: 27));

    final days = List<DateTime>.generate(
      28,
      (i) => DateTime(start.year, start.month, start.day + i),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Last 4 weeks',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
            )),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: days.map((day) {
            final done = habitService.isCompletedOnDate(habit, day);
            final isSelected = day.year == focus.year &&
                day.month == focus.month &&
                day.day == focus.day;

            return Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? const Color(0xFF22C55E)
                    : Colors.white.withOpacity(0.08),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xFF22D3EE),
                        width: 1.2,
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


