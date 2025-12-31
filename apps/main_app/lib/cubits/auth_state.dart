part of 'auth_cubit.dart';

enum AuthStatus { loading, unauthenticated, authenticated }

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.loading) AuthStatus status,
    @Default(false) bool isLoading,
    supa.User? user,
    Map<String, dynamic>? profile,
    String? error,
  }) = _AuthState;
}

