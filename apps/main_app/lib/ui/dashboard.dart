import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_checkin_app/sub_app_widget.dart';
import 'package:habit_insights_app/sub_app_2_widget.dart';
import 'package:main_app/cubits/habit_tracker_cubit.dart';
import 'package:network_layer/network_layer.dart';

/// Main dashboard shown when the user is authenticated.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main App using sub apps')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _HabitSummary(),
              NetworkStatusBanner(),
              SizedBox(height: 24),
              Text('Today\'s Habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              HabitCheckinWidget(),
              SizedBox(height: 16),
              Text('Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              HabitInsightsWidget(),
            ],
          ),
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
