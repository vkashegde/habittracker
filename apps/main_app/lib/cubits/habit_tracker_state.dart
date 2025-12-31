part of 'habit_tracker_cubit.dart';

@freezed
class HabitTrackerState with _$HabitTrackerState {
  const factory HabitTrackerState({
    @Default(false) bool isLoading,
    @Default(0) int totalHabits,
    @Default(0) int completedHabits,
    String? error,
  }) = _HabitTrackerState;
}

