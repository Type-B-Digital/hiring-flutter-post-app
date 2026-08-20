import 'package:equatable/equatable.dart';
import '../../domain/models/username.dart';

class LoginFormState extends Equatable {
  final Username username;
  final String password;
  final bool isValid;

  const LoginFormState({
    this.username = const Username.pure(),
    this.password = '',
    this.isValid = false,
  });

  LoginFormState copyWith({
    Username? username,
    String? password,
    bool? isValid,
  }) {
    return LoginFormState(
      username: username ?? this.username,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [username, password, isValid];
}
