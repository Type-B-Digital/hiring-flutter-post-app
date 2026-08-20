import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posts_app/features/auth/domain/models/username.dart';
import 'package:posts_app/features/auth/presentation/bloc/login_form_bloc.dart';
import 'package:posts_app/features/auth/presentation/bloc/login_form_event.dart';
import 'package:posts_app/features/auth/presentation/bloc/login_form_state.dart';

void main() {
  group('Username', () {
    test('dirty_withEmptyValue_isNotValid', () {
      const username = Username.dirty('');
      expect(username.isValid, false);
      expect(username.error, UsernameValidationError.empty);
    });

    test('dirty_withNonEmptyValue_isValid', () {
      const username = Username.dirty('emilys');
      expect(username.isValid, true);
      expect(username.error, isNull);
    });

    test('pure_defaultsToEmptyAndNotValid', () {
      const username = Username.pure();
      expect(username.value, '');
      expect(username.isValid, false);
    });
  });

  group('LoginFormBloc', () {
    late LoginFormBloc loginFormBloc;

    setUp(() {
      loginFormBloc = LoginFormBloc();
    });

    tearDown(() {
      loginFormBloc.close();
    });

    test('initialState_isPureAndInvalid', () {
      expect(loginFormBloc.state, const LoginFormState());
      expect(loginFormBloc.state.isValid, false);
    });

    blocTest<LoginFormBloc, LoginFormState>(
      'usernameChanged_withNonEmptyValue_emitsValidState',
      build: () => loginFormBloc,
      act: (bloc) => bloc.add(const LoginFormUsernameChanged('emilys')),
      expect: () => [
        isA<LoginFormState>()
            .having((s) => s.username.value, 'username.value', 'emilys')
            .having((s) => s.isValid, 'isValid', true),
      ],
    );

    blocTest<LoginFormBloc, LoginFormState>(
      'usernameChanged_withEmptyValue_emitsInvalidState',
      build: () => loginFormBloc,
      act: (bloc) => bloc.add(const LoginFormUsernameChanged('')),
      expect: () => [
        isA<LoginFormState>().having((s) => s.isValid, 'isValid', false),
      ],
    );

    blocTest<LoginFormBloc, LoginFormState>(
      'passwordChanged_updatesPasswordWithoutAffectingValidity',
      build: () => loginFormBloc,
      act: (bloc) => bloc.add(const LoginFormPasswordChanged('emilyspass')),
      expect: () => [
        const LoginFormState(password: 'emilyspass'),
      ],
    );
  });
}
