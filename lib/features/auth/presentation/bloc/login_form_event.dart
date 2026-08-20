import 'package:equatable/equatable.dart';

abstract class LoginFormEvent extends Equatable {
  const LoginFormEvent();
  @override
  List<Object> get props => [];
}

class LoginFormUsernameChanged extends LoginFormEvent {
  final String username;
  const LoginFormUsernameChanged(this.username);
  @override
  List<Object> get props => [username];
}

class LoginFormPasswordChanged extends LoginFormEvent {
  final String password;
  const LoginFormPasswordChanged(this.password);
  @override
  List<Object> get props => [password];
}
