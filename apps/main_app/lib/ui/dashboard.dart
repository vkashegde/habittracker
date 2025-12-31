import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_checkin_app/sub_app_widget.dart';
import 'package:habit_insights_app/sub_app_2_widget.dart';
import 'package:main_app/cubits/habit_tracker_cubit.dart';
import 'package:main_app/habit_persistence.dart';
import 'package:main_app/ui/habits.dart';
import 'package:network_layer/network_layer.dart';
import 'package:shared/shared.dart';

/// Main dashboard shown when the user is authenticated.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main App using sub apps'),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HabitSummary(),
              const NetworkStatusBanner(),
              const SizedBox(height: 16),
              const _ReminderNudgeBanner(),
              const SizedBox(height: 16),
              const _ManageHabitsCard(),
              const SizedBox(height: 24),
              const Text(
                'Today\'s Habits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const HabitCheckinWidget(),
              const SizedBox(height: 16),
              const Text('Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const HabitInsightsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageHabitsCard extends StatelessWidget {
  const _ManageHabitsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Expanded(
              child: Text('Configure your habits (templates, categories, frequency).'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => const HabitManagementScreen()));
              },
              child: const Text('Manage'),
            ),
          ],
        ),
      ),
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
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
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
          return const LinearProgressIndicator();
        }
        if (state.totalHabits == 0) {
          return const Text('No habits configured yet.');
        }
        return Text(
          'Completed ${state.completedHabits} of ${state.totalHabits} habits today',
          style: const TextStyle(fontSize: 14),
        );
      },
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
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(text)),
            ],
          ),
        );
      },
    );
  }
}
