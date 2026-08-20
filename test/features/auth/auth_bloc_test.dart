import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/core/error/failures.dart';
import 'package:posts_app/core/utils/either.dart';
import 'package:posts_app/features/auth/domain/entities/user.dart';
import 'package:posts_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:posts_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:posts_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:posts_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  const tUser = User(
    id: 1,
    username: 'test',
    email: 'test@test.com',
    firstName: 'Test',
    lastName: 'User',
    image: 'image.png',
    token: 'token123',
  );

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'login_withValidCredentials_emitsLoadingThenAuthenticated',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const AuthLoginRequested(username: 'u', password: 'p')),
      expect: () => [
        AuthLoading(),
        const AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'login_withInvalidCredentials_emitsLoadingThenError',
      build: () {
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async => const Left(AuthFailure('Invalid')));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const AuthLoginRequested(username: 'u', password: 'p')),
      expect: () => [
        AuthLoading(),
        const AuthError('Invalid'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'authCheckRequested_withStoredSession_restoresAuthenticatedState',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        const AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'authCheckRequested_withNoStoredSession_emitsUnauthenticated',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(AuthFailure('No token found')));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'authLogoutRequested_clearsSessionAndEmitsUnauthenticated',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );
  });
}
