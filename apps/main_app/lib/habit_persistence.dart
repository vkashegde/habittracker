import 'dart:convert';

import 'package:shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles offline-first persistence and cloud sync of habit data.
///
/// Local persistence uses `SharedPreferences` so the app works offline
/// across restarts. Cloud sync uses Supabase via the shared `authRepository`
/// and `HabitCloudSync` helper.
class HabitPersistence {
  static const String _prefsKeyPrefix = 'habit_state_';

  static String _prefsKeyForUser(String? userId) {
    if (userId == null) return '${_prefsKeyPrefix}anonymous';
    return '$_prefsKeyPrefix$userId';
  }

  /// Load habits from local storage and, if logged in, from Supabase.
  static Future<void> loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final user = authRepository.currentUser;
    final key = _prefsKeyForUser(user?.id);

    final localJson = prefs.getString(key);
    if (localJson != null) {
      try {
        final decoded = jsonDecode(localJson) as Map<String, Object?>;
        habitService.importState(decoded);
      } catch (_) {
        // Ignore corrupt local data and fall back to defaults.
      }
    }

    // Optional: pull latest state from Supabase if available.
    if (user != null) {
      try {
        final cloud = await HabitCloudSync().loadFromCloud(user.id);
        if (cloud != null) {
          habitService.importState(cloud);
          // Save updated state locally as well.
          final snapshot = habitService.exportState();
          await prefs.setString(key, jsonEncode(snapshot));
        }
      } catch (_) {
        // If cloud sync fails we still have local / in-memory data.
      }
    }
  }

  /// Persist current state locally and push to cloud (if logged in).
  static Future<void> saveAndSync() async {
    final prefs = await SharedPreferences.getInstance();
    final user = authRepository.currentUser;
    final key = _prefsKeyForUser(user?.id);

    final snapshot = habitService.exportState();
    await prefs.setString(key, jsonEncode(snapshot));

    if (user != null) {
      try {
        await HabitCloudSync().saveToCloud(user.id, snapshot);
      } catch (_) {
        // Ignore cloud errors for now – local state is still safe.
      }
    }
  }
}

/// Simple Supabase-backed sync helper that stores one JSON blob per user.
///
/// Expected table schema in Supabase:
///   table: habit_states
///     - user_id (uuid, primary key, references auth.users.id)
///     - data (jsonb)
///     - updated_at (timestamptz, default now())
class HabitCloudSync {
  Future<void> saveToCloud(String userId, Map<String, Object?> data) async {
    await Supabase.instance.client.from('habit_states').upsert(
      <String, Object?>{
        'user_id': userId,
        'data': data,
      },
    );
  }

  Future<Map<String, Object?>?> loadFromCloud(String userId) async {
    final response = await Supabase.instance.client
        .from('habit_states')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    final raw = response['data'];
    if (raw is Map<String, Object?>) return raw;
    return null;
  }
}


