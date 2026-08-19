part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final UserModel user;
  AuthAuthenticatedState(this.user);
}

class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final Failure failure;
  AuthErrorState({required this.failure});
}
