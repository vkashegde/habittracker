import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:main_app/cubits/auth_cubit.dart';
import 'package:main_app/cubits/habit_tracker_cubit.dart';
import 'package:main_app/habit_persistence.dart';
import 'package:main_app/ui/auth.dart';
import 'package:main_app/ui/dashboard.dart';
import 'package:main_app/ui/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (url == null || anonKey == null) {
    throw Exception('SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env');
  }

  await supa.Supabase.initialize(url: url, anonKey: anonKey);

  // Load any locally cached / previously synced habit state before showing UI.
  await HabitPersistence.loadInitialState();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    final neonScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // indigo
      brightness: Brightness.dark,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<HabitTrackerCubit>(create: (_) => HabitTrackerCubit()),
      ],
      child: MaterialApp(
        title: 'Neon Habits',
        theme: base.copyWith(
          colorScheme: neonScheme,
          scaffoldBackgroundColor: const Color(0xFF020617), // near-black
          cardColor: const Color(0xFF0B1120),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
          ),
          textTheme: base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF020617),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF22D3EE)),
            ),
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          chipTheme: base.chipTheme.copyWith(
            backgroundColor: const Color(0xFF020617),
            selectedColor: const Color(0xFF22D3EE).withOpacity(0.2),
            labelStyle: const TextStyle(color: Colors.white),
          ),
          switchTheme: base.switchTheme.copyWith(
            thumbColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? const Color(0xFF22D3EE) : Colors.grey,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFF22D3EE).withOpacity(0.4)
                  : Colors.grey.withOpacity(0.4),
            ),
          ),
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Handles splash -> login/signup -> home routing based on Supabase auth state.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.loading:
            return const SplashScreen();
          case AuthStatus.unauthenticated:
            return const _AuthScreen();
          case AuthStatus.authenticated:
            return const DashboardScreen();
        }
      },
    );
  }
}

class _AuthScreen extends StatelessWidget {
  const _AuthScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: const AuthSection(),
          ),
        ),
      ),
    );
  }
}
