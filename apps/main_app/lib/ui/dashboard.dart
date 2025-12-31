import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main_app/cubits/habit_tracker_cubit.dart';
import 'package:main_app/habit_persistence.dart';
import 'package:main_app/ui/insights_screen.dart';
import 'package:main_app/ui/today_screen.dart';
import 'package:main_app/ui/habits.dart';
import 'package:main_app/ui/meditation.dart';
import 'package:network_layer/network_layer.dart';
import 'package:shared/shared.dart';

/// Main dashboard shown when the user is authenticated.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Neon Habits'),
        actions: [
          IconButton(
            tooltip: 'Sync habits',
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await HabitPersistence.saveAndSync();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Habits synced')));
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-manage-habits',
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const HabitManagementScreen()));
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Manage habits'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1D1B4C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _DashboardHeader(),
                  const SizedBox(height: 20),
                  const _ReminderNudgeBanner(),
                  const SizedBox(height: 24),
                  const _TodaySectionHeader(),
                  const SizedBox(height: 12),
                  const _TodayHabitsPreview(),
                  const SizedBox(height: 24),
                  const _MeditationCard(),
                  const SizedBox(height: 24),
                  _InsightsButton(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: (_) => const InsightsScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _greetingForHour(now.hour);
    final formattedDate =
        '${now.day.toString().padLeft(2, '0')} ${_monthLabel(now.month)}, ${now.year}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1120), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.45),
            blurRadius: 28,
            spreadRadius: -12,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF6366F1)]),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22D3EE).withOpacity(0.45),
                  blurRadius: 24,
                  spreadRadius: -10,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Let\'s keep your streaks glowing today.',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}

class _TodaySectionHeader extends StatelessWidget {
  const _TodaySectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Completed snapshot of your daily glow‑ups.',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
        const Spacer(),
        const _HabitSummary(),
      ],
    );
  }
}

/// In-app smart nudge banner for incomplete habits.
class _ReminderNudgeBanner extends StatelessWidget {
  const _ReminderNudgeBanner();

  @override
  Widget build(BuildContext context) {
    final todayHabits = habitService.getTodayHabits();
    final remaining = todayHabits.where((h) => !h.completed).length;

    if (remaining == 0) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final hour = now.hour;

    String title;
    String body;

    if (hour < 12) {
      title = 'Gentle morning nudge';
      body = 'You have $remaining habit(s) planned for today. Start with one now?';
    } else if (hour < 18) {
      title = 'Midday check-in';
      body = 'Still $remaining habit(s) open. Take a quick break to check in?';
    } else {
      title = 'Evening wrap-up';
      body = 'Day is almost over and $remaining habit(s) are left. Missed reminder? Try now.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFF97316).withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, size: 18, color: Color(0xFFF97316)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsButton extends StatelessWidget {
  const _InsightsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final todayHabits = habitService.getTodayHabits();
    final total = todayHabits.length;
    final completed = todayHabits.where((h) => h.completed).length;
    final completionRatio = total == 0 ? 0.0 : completed / total;

    final summaryText = total == 0
        ? 'No habits logged yet – start a streak today.'
        : '$completed of $total habits done today.';

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF020617), Color(0xFF111827)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.55)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.45),
              blurRadius: 26,
              spreadRadius: -10,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.5),
                    blurRadius: 22,
                    spreadRadius: -8,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: const Icon(Icons.insights_rounded, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Insights',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Streaks, calendar, and habit trends in one place.',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summaryText,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.92),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: completionRatio.clamp(0, 1),
                                  backgroundColor: Colors.white.withOpacity(0.12),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF22D3EE),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact preview on the home screen that only shows today's habit names.
class _TodayHabitsPreview extends StatelessWidget {
  const _TodayHabitsPreview();

  @override
  Widget build(BuildContext context) {
    final todayHabits = habitService.getTodayHabits();
    final total = todayHabits.length;
    final completed = todayHabits.where((h) => h.completed).length;
    final completionRatio = total == 0 ? 0.0 : completed / total;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const TodayHabitsScreen()));
      },
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF020617), Color(0xFF111827)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.55)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22D3EE).withOpacity(0.45),
              blurRadius: 28,
              spreadRadius: -12,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF6366F1)]),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22D3EE).withOpacity(0.5),
                        blurRadius: 22,
                        spreadRadius: -8,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.today, color: Colors.black, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s habits',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        total == 0
                            ? 'No habits planned yet – set one to start your streak.'
                            : 'Quick snapshot of what\'s on for today.',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.72)),
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
                      color: Colors.black.withOpacity(0.28),
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
                          width: 82,
                          height: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: completionRatio.clamp(0, 1),
                              backgroundColor: Colors.white.withOpacity(0.12),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (todayHabits.isEmpty)
              Text(
                'No habits queued for today. Tap to add or configure your routine.',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final status in todayHabits.take(6)) _TodayHabitChip(status: status),
                    ],
                  ),
                  if (todayHabits.length > 6)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '+ ${todayHabits.length - 6} more habit(s) in today\'s check-in',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 10),
            Text(
              'Tap to open full check-in.',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.65)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationCard extends StatelessWidget {
  const _MeditationCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const MeditationScreen()));
      },
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF0B1120), Color(0xFF111827), Color(0xFF1E1B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA855F7).withOpacity(0.5),
              blurRadius: 26,
              spreadRadius: -10,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF6366F1)]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withOpacity(0.6),
                    blurRadius: 24,
                    spreadRadius: -10,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: const Icon(Icons.self_improvement, color: Colors.black, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meditation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Drop into a guided breathing timer for 5–60 minutes of focus and calm.',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.82)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Open',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitSummary extends StatelessWidget {
  const _HabitSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitTrackerCubit, HabitTrackerState>(
      builder: (context, state) {
        if (state.isLoading) {
          return SizedBox(
            width: 96,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22D3EE)),
            ),
          );
        }

        if (state.totalHabits == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 16, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 6),
                const Text(
                  'No habits yet',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        final completionRatio = state.totalHabits == 0
            ? 0.0
            : state.completedHabits / state.totalHabits;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22D3EE).withOpacity(0.4),
                blurRadius: 18,
                spreadRadius: -8,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.22),
                ),
                child: Center(
                  child: Text(
                    '${(completionRatio * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.completedHabits} of ${state.totalHabits} done',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 90,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: completionRatio.clamp(0, 1),
                        backgroundColor: Colors.white.withOpacity(0.18),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBBF7D0)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TodayHabitChip extends StatelessWidget {
  const _TodayHabitChip({required this.status});

  final TodayHabitStatus status;

  @override
  Widget build(BuildContext context) {
    final habit = status.habit;
    final completed = status.completed;
    final target = habit.dailyTarget;
    final amount = status.amount;

    String subtitle = '';
    if (target != null && target > 0) {
      subtitle = '$amount / $target';
    } else if (completed) {
      subtitle = 'Done for today';
    } else {
      subtitle = 'Not done yet';
    }

    final baseColor = completed ? const Color(0xFF22C55E) : const Color(0xFF22D3EE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: completed ? baseColor.withOpacity(0.18) : Colors.white.withOpacity(0.03),
        border: Border.all(color: completed ? baseColor : Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: completed ? baseColor : Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(habit.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small banner showing shared network-layer usage.
class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: NetworkLayer.client.getStatus(),
      builder: (context, snapshot) {
        final text = switch (snapshot.connectionState) {
          ConnectionState.waiting => 'Checking API status...',
          ConnectionState.done =>
            snapshot.hasError ? 'API error' : snapshot.data ?? 'Unknown status',
          _ => 'Checking API status...',
        };

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF020617).withOpacity(0.9),
            border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud, size: 18, color: Color(0xFF22D3EE)),
              const SizedBox(width: 8),
              Flexible(child: Text(text, style: const TextStyle(fontSize: 12))),
            ],
          ),
        );
      },
    );
  }
}
