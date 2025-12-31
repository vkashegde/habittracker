library shared;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Type of habit being tracked.
enum HabitType {
  /// Simple yes/no completion for the day (e.g. "Did you meditate?").
  boolean,

  /// Count-based habits (e.g. "Drink 8 glasses of water").
  count,

  /// Duration-based habits (e.g. "Exercise 30 minutes").
  duration,
}

/// A habit definition shared across all apps.
class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.dailyTarget,
  });

  final String id;
  final String name;
  final String description;
  final HabitType type;

  /// Target amount per day, if applicable (count or minutes).
  final int? dailyTarget;
}

/// A log entry for a given habit on a specific day.
class HabitLog {
  HabitLog({required this.habitId, required this.date, this.completed = false, this.amount});

  final String habitId;
  final DateTime date;
  final bool completed;

  /// Numeric amount for count/duration habits.
  final int? amount;
}

/// Basic repository interface for habits and their logs.
abstract class HabitRepository {
  List<Habit> getHabits();

  bool isCompletedOn(String habitId, DateTime day);

  void toggleCompletedOn(String habitId, DateTime day);

  /// Returns all days in which the habit was completed.
  Iterable<DateTime> completedDays(String habitId);
}

/// In-memory implementation with some seeded demo data.
class InMemoryHabitRepository implements HabitRepository {
  InMemoryHabitRepository._(this._habits);

  factory InMemoryHabitRepository.seeded() {
    return InMemoryHabitRepository._([
      Habit(
        id: 'run',
        name: 'Run 5km',
        description: 'Go for a 5km run or 30 minutes of jogging.',
        type: HabitType.duration,
        dailyTarget: 30,
      ),
      Habit(
        id: 'water',
        name: 'Drink water',
        description: 'Drink at least 8 glasses (2L) of water.',
        type: HabitType.count,
        dailyTarget: 8,
      ),
      Habit(
        id: 'meditate',
        name: 'Meditate',
        description: 'Meditate for at least 10 minutes.',
        type: HabitType.duration,
        dailyTarget: 10,
      ),
    ]);
  }

  final List<Habit> _habits;

  /// Map of habitId -> set of dates (day precision) when completed.
  final Map<String, Set<DateTime>> _completedDays = {};

  DateTime _asDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  List<Habit> getHabits() => List.unmodifiable(_habits);

  @override
  bool isCompletedOn(String habitId, DateTime day) {
    final d = _asDay(day);
    final set = _completedDays[habitId];
    if (set == null) return false;
    return set.contains(d);
  }

  @override
  void toggleCompletedOn(String habitId, DateTime day) {
    final d = _asDay(day);
    final set = _completedDays.putIfAbsent(habitId, () => <DateTime>{});
    if (!set.add(d)) {
      // Was already present; remove to toggle off.
      set.remove(d);
    }
  }

  @override
  Iterable<DateTime> completedDays(String habitId) sync* {
    final set = _completedDays[habitId];
    if (set == null) return;
    for (final d in set) {
      yield d;
    }
  }
}

/// Convenience view model representing a habit and whether it is done today.
class TodayHabitStatus {
  TodayHabitStatus({required this.habit, required this.completed});

  final Habit habit;
  final bool completed;
}

/// High-level API that all apps can use to work with habits.
class HabitService {
  HabitService({HabitRepository? repository})
    : _repository = repository ?? InMemoryHabitRepository.seeded();

  final HabitRepository _repository;

  DateTime _today() => DateTime.now();

  /// All habits.
  List<Habit> getAllHabits() => _repository.getHabits();

  /// Habits with completion status for today.
  List<TodayHabitStatus> getTodayHabits() {
    final today = _today();
    return _repository
        .getHabits()
        .map((h) => TodayHabitStatus(habit: h, completed: _repository.isCompletedOn(h.id, today)))
        .toList();
  }

  /// Toggle completion state for the given habit today.
  void toggleHabitForToday(Habit habit) {
    _repository.toggleCompletedOn(habit.id, _today());
  }

  /// Compute the current streak (consecutive completed days up to today).
  int streakForHabit(Habit habit) {
    final completed = _repository.completedDays(habit.id).toSet();
    if (completed.isEmpty) return 0;

    var streak = 0;
    var cursor = DateTime.now();

    while (true) {
      final day = DateTime(cursor.year, cursor.month, cursor.day);
      if (!completed.contains(day)) break;
      streak += 1;
      cursor = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Number of days completed in the last [days] days (inclusive of today).
  int completionsInLastDays(Habit habit, int days) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(Duration(days: days - 1));

    final completed = _repository
        .completedDays(habit.id)
        .map((d) => DateTime(d.year, d.month, d.day))
        .where((d) => !d.isBefore(start) && !d.isAfter(today))
        .toSet();

    return completed.length;
  }
}

/// A shared singleton-style service instance that all apps can use.
final HabitService habitService = HabitService();

/// Simple authentication repository backed by Supabase.
class AuthRepository {
  AuthRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  /// Sign in with email + password.
  Future<AuthResponse> signInWithEmail({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign up with email + password.
  Future<AuthResponse> signUpWithEmail({required String email, required String password}) {
    return _client.auth.signUp(email: email, password: password);
  }

  /// Sign out the current user.
  Future<void> signOut() => _client.auth.signOut();
}

/// Repository for storing simple user profile data in Supabase.
///
/// Expects a `profiles` table with at least:
///   - `id` (uuid, primary key, references auth.users.id)
///   - `display_name` (text, nullable)
class UserProfileRepository {
  UserProfileRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> upsertProfile({required String userId, required String displayName}) async {
    await _client.from('profiles').upsert({'id': userId, 'display_name': displayName});
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }
}

/// Shared singletons for auth and user profiles.
final AuthRepository authRepository = AuthRepository();
final UserProfileRepository userProfileRepository = UserProfileRepository();
