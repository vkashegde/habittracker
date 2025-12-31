import 'package:flutter/material.dart';
import 'package:habit_checkin_app/sub_app_widget.dart';

/// Full-screen page for checking in to today's habits with full detail.
class TodayHabitsScreen extends StatelessWidget {
  const TodayHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Habits'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1D1B4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: HabitCheckinWidget(),
          ),
        ),
      ),
    );
  }
}


