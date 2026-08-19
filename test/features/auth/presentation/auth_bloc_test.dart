import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/features/auth/domain/auth_repository.dart';
import 'package:postsapp/features/auth/domain/user_model.dart';
import 'package:postsapp/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late UserModel testUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    testUser = const UserModel(
      id: 1,
      username: 'emilys',
      email: 'emily.johnson@x.dummyjson.com',
      accessToken: 'fake-access-token',
    );
  });

  group('LoginButtonClickedEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(
          () => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Result.success(testUser));
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(LoginButtonClickedEvent('emilys', 'emilyspass')),
      expect: () => [isA<AuthLoadingState>(), isA<AuthAuthenticatedState>()],
      verify: (_) {
        verify(
          () => mockAuthRepository.login(
            username: 'emilys',
            password: 'emilyspass',
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with InvalidCredentialsFailure',
      build: () {
        when(
          () => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => Result.failure(const InvalidCredentialsFailure()),
        );
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(LoginButtonClickedEvent('emilys', 'wrongpass')),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthErrorState>().having(
          (state) => state.failure,
          'failure',
          isA<InvalidCredentialsFailure>(),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with NetworkFailure',
      build: () {
        when(
          () => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Result.failure(const NetworkFailure()));
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(LoginButtonClickedEvent('emilys', 'emilyspass')),
      expect: () => [
        isA<AuthLoadingState>(),
        isA<AuthErrorState>().having(
          (state) => state.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      ],
    );
  });

  group('SessionCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when a valid session exists',
      build: () {
        when(
          () => mockAuthRepository.restoreSession(),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(SessionCheckRequestedEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<AuthAuthenticatedState>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no session exists',
      build: () {
        when(
          () => mockAuthRepository.restoreSession(),
        ).thenAnswer((_) async => null);
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(SessionCheckRequestedEvent()),
      expect: () => [isA<AuthLoadingState>(), isA<AuthUnauthenticatedState>()],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when logout is requested',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(mockAuthRepository);
      },
      act: (bloc) => bloc.add(LogoutButtonClickedEvent()),
      expect: () => [isA<AuthUnauthenticatedState>()],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );
  });
}
