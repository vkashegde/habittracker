import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:main_app/cubits/auth_cubit.dart';
import 'package:main_app/cubits/habit_tracker_cubit.dart';
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
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<HabitTrackerCubit>(create: (_) => HabitTrackerCubit()),
      ],
      child: MaterialApp(
        title: 'Main App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
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
