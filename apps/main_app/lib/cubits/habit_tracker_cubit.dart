import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'habit_tracker_cubit.freezed.dart';
part 'habit_tracker_state.dart';

/// Cubit to expose a simple view of today's habits and completion summary.
class HabitTrackerCubit extends Cubit<HabitTrackerState> {
  HabitTrackerCubit() : super(const HabitTrackerState()) {
    loadTodayHabits();
  }

  Future<void> loadTodayHabits() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final todayHabits = habitService.getTodayHabits();
      final total = todayHabits.length;
      final completed = todayHabits.where((h) => h.completed).length;
      emit(
        state.copyWith(
          isLoading: false,
          totalHabits: total,
          completedHabits: completed,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to load habits: $e'));
    }
  }

  Future<void> toggleHabit(TodayHabitStatus status) async {
    try {
      habitService.toggleHabitForToday(status.habit);
      await loadTodayHabits();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to toggle habit: $e'));
    }
  }
}
