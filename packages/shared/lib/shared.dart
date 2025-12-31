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

/// High‑level life area / bucket a habit belongs to.
///
/// This is used to power templates like Health, Learning, Fitness, etc.
enum HabitCategory { health, learning, fitness, work, spiritual, finance, other }

/// Frequency configuration for when a habit should show up.
///
/// This keeps the logic for "is this habit due today?" in one place so that
/// all apps (tracking, insights, main_app) stay in sync.
enum HabitFrequencyType {
  /// Appears every day.
  daily,

  /// Target number of completions per week (e.g. 3x/week).
  ///
  /// For now we surface these habits every day in the "today" list but use
  /// [timesPerWeek] as a goal in insights.
  weeklyTimes,

  /// Only on specific weekdays (e.g. Mon/Wed/Fri).
  specificDays,
}

/// Schedule describing when a habit is due.
class HabitSchedule {
  const HabitSchedule._(this.type, {this.timesPerWeek, this.daysOfWeek});

  /// Convenience constructor for a daily habit.
  const HabitSchedule.daily() : this._(HabitFrequencyType.daily);

  /// Convenience constructor for a habit that should be completed
  /// [timesPerWeek] times per week.
  const HabitSchedule.weeklyTimes(int timesPerWeek)
    : this._(HabitFrequencyType.weeklyTimes, timesPerWeek: timesPerWeek);

  /// Convenience constructor for a habit that is only due on specific
  /// weekdays (1 = Monday, 7 = Sunday as in [DateTime.weekday]).
  const HabitSchedule.specificDays(Set<int> daysOfWeek)
    : this._(HabitFrequencyType.specificDays, daysOfWeek: daysOfWeek);

  final HabitFrequencyType type;

  /// Target completions per week for [HabitFrequencyType.weeklyTimes].
  final int? timesPerWeek;

  /// Weekdays on which the habit is due for [HabitFrequencyType.specificDays].
  ///
  /// Uses the same range as [DateTime.weekday]: 1 (Monday) .. 7 (Sunday).
  final Set<int>? daysOfWeek;

  /// Returns true if this habit should appear in the "today" list for [day].
  ///
  /// For `weeklyTimes` we currently surface the habit every day; the
  /// [timesPerWeek] value is interpreted by insights/stats to determine if the
  /// user is on track for the week.
  bool isDueOn(DateTime day) {
    switch (type) {
      case HabitFrequencyType.daily:
        return true;
      case HabitFrequencyType.weeklyTimes:
        return true;
      case HabitFrequencyType.specificDays:
        final set = daysOfWeek;
        if (set == null || set.isEmpty) return true;
        return set.contains(day.weekday);
    }
  }
}

/// A reusable template for quickly creating common habits.
class HabitTemplate {
  const HabitTemplate({
    required this.name,
    required this.description,
    required this.type,
    this.dailyTarget,
    this.category = HabitCategory.other,
    this.schedule = const HabitSchedule.daily(),
  });

  final String name;
  final String description;
  final HabitType type;
  final int? dailyTarget;
  final HabitCategory category;
  final HabitSchedule schedule;
}

/// Default templates grouped roughly by life area.
const List<HabitTemplate> defaultHabitTemplates = <HabitTemplate>[
  HabitTemplate(
    name: 'Drink water',
    description: 'Drink at least 8 glasses (2L) of water.',
    type: HabitType.count,
    dailyTarget: 8,
    category: HabitCategory.health,
  ),
  HabitTemplate(
    name: 'Meditate',
    description: 'Meditate for at least 10 minutes.',
    type: HabitType.duration,
    dailyTarget: 10,
    category: HabitCategory.spiritual,
  ),
  HabitTemplate(
    name: 'Read 20 minutes',
    description: 'Focused reading or learning for 20 minutes.',
    type: HabitType.duration,
    dailyTarget: 20,
    category: HabitCategory.learning,
  ),
  HabitTemplate(
    name: 'Workout',
    description: 'Strength or cardio workout.',
    type: HabitType.duration,
    dailyTarget: 30,
    category: HabitCategory.fitness,
  ),
  HabitTemplate(
    name: 'Daily planning',
    description: 'Plan your work for the day.',
    type: HabitType.boolean,
    category: HabitCategory.work,
  ),
  HabitTemplate(
    name: 'Weekly budget review',
    description: 'Review spending and adjust your budget.',
    type: HabitType.boolean,
    category: HabitCategory.finance,
    schedule: HabitSchedule.weeklyTimes(1),
  ),
];

/// A habit definition shared across all apps.
class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.dailyTarget,
    HabitCategory? category,
    HabitSchedule? schedule,
  }) : category = category ?? HabitCategory.other,
       schedule = schedule ?? const HabitSchedule.daily();

  final String id;
  final String name;
  final String description;
  final HabitType type;

  /// Target amount per day, if applicable (count or minutes).
  final int? dailyTarget;

  /// High-level life area (Health, Learning, Fitness, etc.).
  final HabitCategory category;

  /// Frequency configuration for when the habit is due.
  final HabitSchedule schedule;
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

  /// Add a new habit to the repository.
  void addHabit(Habit habit);

  /// Update an existing habit (matched by [Habit.id]).
  ///
  /// If the habit does not yet exist it will be added.
  void updateHabit(Habit habit);

  /// Remove a habit and any associated completion data.
  void deleteHabit(String habitId);

  /// Numeric amount recorded for a habit on [day] (0 if none).
  int getAmountOn(String habitId, DateTime day);

  /// Set the numeric amount for a habit on [day].
  void setAmountOn(String habitId, DateTime day, int amount);

  bool isCompletedOn(String habitId, DateTime day);

  void toggleCompletedOn(String habitId, DateTime day);

  /// Returns all days in which the habit was completed.
  Iterable<DateTime> completedDays(String habitId);

  /// Export the current repository state to a JSON-safe map.
  Map<String, Object?> exportState();

  /// Replace the current repository state from a JSON-safe map.
  void importState(Map<String, Object?> data);
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
        category: HabitCategory.fitness,
      ),
      Habit(
        id: 'water',
        name: 'Drink water',
        description: 'Drink at least 8 glasses (2L) of water.',
        type: HabitType.count,
        dailyTarget: 8,
        category: HabitCategory.health,
      ),
      Habit(
        id: 'meditate',
        name: 'Meditate',
        description: 'Meditate for at least 10 minutes.',
        type: HabitType.duration,
        dailyTarget: 10,
        category: HabitCategory.spiritual,
      ),
    ]);
  }

  final List<Habit> _habits;

  /// Map of habitId -> map of day -> log entry.
  final Map<String, Map<DateTime, HabitLog>> _logsByHabit = {};

  DateTime _asDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Habit? _findHabit(String habitId) {
    for (final h in _habits) {
      if (h.id == habitId) return h;
    }
    return null;
  }

  @override
  List<Habit> getHabits() => List.unmodifiable(_habits);

  @override
  void addHabit(Habit habit) {
    _habits.add(habit);
  }

  @override
  void updateHabit(Habit habit) {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) {
      _habits.add(habit);
    } else {
      _habits[index] = habit;
    }
  }

  @override
  void deleteHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _logsByHabit.remove(habitId);
  }

  @override
  int getAmountOn(String habitId, DateTime day) {
    final d = _asDay(day);
    final logs = _logsByHabit[habitId];
    final log = logs?[d];
    return log?.amount ?? 0;
  }

  @override
  void setAmountOn(String habitId, DateTime day, int amount) {
    final d = _asDay(day);
    final logs = _logsByHabit.putIfAbsent(habitId, () => <DateTime, HabitLog>{});
    final existing = logs[d];
    logs[d] = HabitLog(
      habitId: habitId,
      date: d,
      completed: existing?.completed ?? false,
      amount: amount,
    );
  }

  @override
  bool isCompletedOn(String habitId, DateTime day) {
    final d = _asDay(day);
    final logs = _logsByHabit[habitId];
    final log = logs?[d];
    if (log == null) return false;

    final habit = _findHabit(habitId);
    if (habit == null) return log.completed;

    // Boolean habits rely solely on the completed flag.
    if (habit.type == HabitType.boolean) return log.completed;

    // Counter / duration habits are considered complete when amount >= target (if any).
    final target = habit.dailyTarget;
    if (target == null) return log.completed;
    final amount = log.amount ?? 0;
    return amount >= target;
  }

  @override
  void toggleCompletedOn(String habitId, DateTime day) {
    final d = _asDay(day);
    final logs = _logsByHabit.putIfAbsent(habitId, () => <DateTime, HabitLog>{});
    final existing = logs[d];
    final amount = existing?.amount;
    final completed = !(existing?.completed ?? false);
    logs[d] = HabitLog(habitId: habitId, date: d, completed: completed, amount: amount);
  }

  @override
  Iterable<DateTime> completedDays(String habitId) sync* {
    final logs = _logsByHabit[habitId];
    if (logs == null) return;
    for (final entry in logs.entries) {
      if (isCompletedOn(habitId, entry.key)) {
        yield entry.key;
      }
    }
  }

  @override
  Map<String, Object?> exportState() {
    return <String, Object?>{
      'habits': _habits
          .map(
            (h) => <String, Object?>{
              'id': h.id,
              'name': h.name,
              'description': h.description,
              'type': h.type.name,
              'dailyTarget': h.dailyTarget,
              'category': h.category.name,
              'schedule': <String, Object?>{
                'frequencyType': h.schedule.type.name,
                'timesPerWeek': h.schedule.timesPerWeek,
                'daysOfWeek': h.schedule.daysOfWeek?.toList(),
              },
            },
          )
          .toList(),
      'logs': _logsByHabit.map(
        (habitId, logsForHabit) => MapEntry<String, Object?>(
          habitId,
          logsForHabit.values
              .map(
                (log) => <String, Object?>{
                  'date': log.date.toIso8601String(),
                  'completed': log.completed,
                  'amount': log.amount,
                },
              )
              .toList(),
        ),
      ),
    };
  }

  @override
  void importState(Map<String, Object?> data) {
    final rawHabits = data['habits'];
    final rawLogs = data['logs'];

    _habits..clear();

    if (rawHabits is List) {
      for (final h in rawHabits) {
        if (h is! Map) continue;
        final id = h['id'] as String?;
        final name = h['name'] as String?;
        final description = h['description'] as String?;
        final typeStr = h['type'] as String?;
        if (id == null || name == null || description == null || typeStr == null) continue;

        final type = HabitType.values.firstWhere(
          (t) => t.name == typeStr,
          orElse: () => HabitType.boolean,
        );

        final dailyTarget = h['dailyTarget'] as int?;

        final categoryStr = h['category'] as String?;
        final category = categoryStr != null
            ? HabitCategory.values.firstWhere(
                (c) => c.name == categoryStr,
                orElse: () => HabitCategory.other,
              )
            : HabitCategory.other;

        final scheduleMap = h['schedule'] as Map<Object?, Object?>?;
        HabitSchedule schedule = const HabitSchedule.daily();
        if (scheduleMap != null) {
          final freqStr = scheduleMap['frequencyType'] as String?;
          final timesPerWeek = scheduleMap['timesPerWeek'] as int?;
          final daysRaw = scheduleMap['daysOfWeek'];

          final freq = freqStr != null
              ? HabitFrequencyType.values.firstWhere(
                  (f) => f.name == freqStr,
                  orElse: () => HabitFrequencyType.daily,
                )
              : HabitFrequencyType.daily;

          switch (freq) {
            case HabitFrequencyType.daily:
              schedule = const HabitSchedule.daily();
              break;
            case HabitFrequencyType.weeklyTimes:
              schedule = HabitSchedule.weeklyTimes(timesPerWeek ?? 1);
              break;
            case HabitFrequencyType.specificDays:
              final days = <int>{};
              if (daysRaw is List) {
                for (final d in daysRaw) {
                  if (d is int) days.add(d);
                }
              }
              schedule = HabitSchedule.specificDays(days);
              break;
          }
        }

        _habits.add(
          Habit(
            id: id,
            name: name,
            description: description,
            type: type,
            dailyTarget: dailyTarget,
            category: category,
            schedule: schedule,
          ),
        );
      }
    }

    _logsByHabit..clear();

    if (rawLogs is Map) {
      rawLogs.forEach((key, value) {
        final habitId = key as String;
        final list = value;
        if (list is! List) return;
        final Map<DateTime, HabitLog> logsForHabit = <DateTime, HabitLog>{};
        for (final rawLog in list) {
          if (rawLog is! Map) continue;
          final dateStr = rawLog['date'] as String?;
          if (dateStr == null) continue;
          DateTime? date;
          try {
            date = DateTime.parse(dateStr);
          } catch (_) {
            continue;
          }
          final completed = rawLog['completed'] as bool? ?? false;
          final amount = rawLog['amount'] as int?;
          logsForHabit[DateTime(date.year, date.month, date.day)] = HabitLog(
            habitId: habitId,
            date: date,
            completed: completed,
            amount: amount,
          );
        }
        if (logsForHabit.isNotEmpty) {
          _logsByHabit[habitId] = logsForHabit;
        }
      });
    }
  }
}

/// Convenience view model representing a habit and whether it is done today.
class TodayHabitStatus {
  TodayHabitStatus({required this.habit, required this.completed, required this.amount});

  final Habit habit;
  final bool completed;

  /// Numeric progress for today (0 for yes/no habits).
  final int amount;
}

/// High-level API that all apps can use to work with habits.
class HabitService {
  HabitService({HabitRepository? repository})
    : _repository = repository ?? InMemoryHabitRepository.seeded();

  final HabitRepository _repository;

  DateTime _today() => DateTime.now();

  /// All habits.
  List<Habit> getAllHabits() => _repository.getHabits();

  /// Current numeric amount for today (0 if none).
  int amountForToday(Habit habit) => _repository.getAmountOn(habit.id, _today());

  /// Set the numeric amount for today.
  void setAmountForToday(Habit habit, int amount) {
    _repository.setAmountOn(habit.id, _today(), amount);
  }

  /// Whether [habit] was completed on a specific calendar [day].
  bool isCompletedOnDate(Habit habit, DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _repository.isCompletedOn(habit.id, d);
  }

  /// Export the current habit state to a JSON-safe map.
  Map<String, Object?> exportState() => _repository.exportState();

  /// Replace the current habit state from a JSON-safe map.
  void importState(Map<String, Object?> data) => _repository.importState(data);

  /// Create a new habit with a generated id and add it to the repository.
  Habit createHabit({
    required String name,
    required String description,
    required HabitType type,
    int? dailyTarget,
    HabitCategory? category,
    HabitSchedule? schedule,
  }) {
    final id = _generateId(name);
    final habit = Habit(
      id: id,
      name: name,
      description: description,
      type: type,
      dailyTarget: dailyTarget,
      category: category,
      schedule: schedule,
    );
    _repository.addHabit(habit);
    return habit;
  }

  /// Update an existing habit definition.
  void updateHabit(Habit habit) {
    _repository.updateHabit(habit);
  }

  /// Delete a habit (and its completion history).
  void deleteHabit(String habitId) {
    _repository.deleteHabit(habitId);
  }

  /// Habits with completion status for today.
  List<TodayHabitStatus> getTodayHabits() {
    final today = _today();
    return _repository
        .getHabits()
        .where((h) => h.schedule.isDueOn(today))
        .map(
          (h) => TodayHabitStatus(
            habit: h,
            completed: _repository.isCompletedOn(h.id, today),
            amount: _repository.getAmountOn(h.id, today),
          ),
        )
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

  /// Simple id generator based on the habit name and current timestamp.
  String _generateId(String baseName) {
    final sanitized = baseName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${sanitized}_$ts';
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
