import 'package:flutter/material.dart';
import 'package:habit_insights_app/sub_app_2_widget.dart';
import 'package:shared/shared.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Full-screen insights page with more breathing room for charts, calendar and streaks.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  /// Currently selected calendar day; defaults to "today" when the page opens.
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final completionDays = habitService.allCompletionDays().toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1D1B4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HabitCalendar(
                  completionDays: completionDays,
                  selectedDay: _selectedDay,
                  onDaySelected: (day) {
                    if (!mounted) return;
                    setState(() {
                      _selectedDay = DateTime(day.year, day.month, day.day);
                    });
                  },
                ),
                const SizedBox(height: 16),
                HabitInsightsWidget(selectedDay: _selectedDay),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rich monthly calendar view built with Syncfusion Flutter Calendar.
///
/// Shows days with at least one completed habit as small neon dots.
class _HabitCalendar extends StatelessWidget {
  const _HabitCalendar({
    required this.completionDays,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final List<DateTime> completionDays;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF020617).withOpacity(0.9),
        border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22D3EE).withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completion calendar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'See which days you showed up. Tap a day to drill into your streaks.',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SfCalendar(
                backgroundColor: Colors.transparent,
                view: CalendarView.month,
                dataSource: _CompletionDataSource(completionDays),
                firstDayOfWeek: 1,
                todayHighlightColor: const Color(0xFF22D3EE),
                onSelectionChanged: (details) {
                  final date = details.date;
                  if (date != null) {
                    onDaySelected(DateTime(date.year, date.month, date.day));
                  }
                },
                selectionDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF6366F1)),
                  color: Colors.white.withOpacity(0.05),
                ),
                monthViewSettings: const MonthViewSettings(
                  showAgenda: false,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionAppointment {
  _CompletionAppointment(this.date);

  final DateTime date;
}

class _CompletionDataSource extends CalendarDataSource {
  _CompletionDataSource(List<DateTime> days) {
    appointments = days
        .map((d) => _CompletionAppointment(DateTime(d.year, d.month, d.day, 9)))
        .toList();
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index] as _CompletionAppointment).date;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index] as _CompletionAppointment).date.add(const Duration(hours: 1));
  }

  @override
  String getSubject(int index) => 'Completed';

  @override
  Color getColor(int index) => const Color(0xFF22C55E); // neon green dots

  @override
  bool isAllDay(int index) => true;
}
