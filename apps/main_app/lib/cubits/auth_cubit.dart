import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

/// Cubit that manages authentication and basic profile state using Supabase.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState()) {
    _init();
  }

  StreamSubscription<supa.AuthState>? _sub;

  Future<void> _init() async {
    // Use current user at startup.
    final user = authRepository.currentUser;
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else {
      await _loadProfileFor(user);
    }

    // Listen for Supabase auth state changes.
    _sub = supa.Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      final user = session?.user;
      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      } else {
        await _loadProfileFor(user);
      }
    });
  }

  Future<void> _loadProfileFor(supa.User user) async {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      isLoading: true,
      user: user,
      error: null,
    ));
    try {
      final profile = await userProfileRepository.getProfile(user.id);
      emit(state.copyWith(
        isLoading: false,
        profile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: $e',
      ));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response =
          await authRepository.signInWithEmail(email: email, password: password);
      final user = response.user;
      if (user != null) {
        await _loadProfileFor(user);
      } else {
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
          error: 'No user returned from Supabase.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Auth error: $e',
      ));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response =
          await authRepository.signUpWithEmail(email: email, password: password);
      final user = response.user;
      if (user != null) {
        final guessedName = email.split('@').first;
        await userProfileRepository.upsertProfile(
          userId: user.id,
          displayName: guessedName,
        );
        await _loadProfileFor(user);
      } else {
        emit(state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
          error: 'No user returned from Supabase.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Auth error: $e',
      ));
    }
  }

  Future<void> saveProfile(String displayName) async {
    final user = state.user;
    if (user == null) return;

    emit(state.copyWith(isLoading: true, error: null));
    try {
      await userProfileRepository.upsertProfile(
        userId: user.id,
        displayName: displayName,
      );
      await _loadProfileFor(user);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to save profile: $e',
      ));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await authRepository.signOut();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to sign out: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}


