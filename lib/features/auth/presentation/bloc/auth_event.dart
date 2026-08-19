part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class LoginButtonClickedEvent extends AuthEvent {
  final String username;
  final String password;
  LoginButtonClickedEvent(this.username, this.password);
}

class LogoutButtonClickedEvent extends AuthEvent {}

class SessionCheckRequestedEvent extends AuthEvent {}
