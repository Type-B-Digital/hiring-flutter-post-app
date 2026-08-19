import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/features/auth/domain/auth_repository.dart';
import 'package:postsapp/features/auth/domain/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginButtonClickedEvent>(_onLoginClicked);
    on<LogoutButtonClickedEvent>(_onLogoutClicked);
    on<SessionCheckRequestedEvent>(_onSessionCheckRequested);
  }

  Future<void> _onLoginClicked(
    LoginButtonClickedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    final result = await authRepository.login(
      username: event.username,
      password: event.password,
    );

    switch (result) {
      case Success(:final data):
        emit(AuthAuthenticatedState(data));
      case Error(:final failure):
        emit(AuthErrorState(failure: failure));
    }
  }

  Future<void> _onLogoutClicked(
    LogoutButtonClickedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    await authRepository.logout();

    emit(AuthUnauthenticatedState());
  }

  Future<void> _onSessionCheckRequested(
    SessionCheckRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    final user = await authRepository.restoreSession();

    if (user != null) {
      emit(AuthAuthenticatedState(user));
    } else {
      emit(AuthUnauthenticatedState());
    }
  }
}
