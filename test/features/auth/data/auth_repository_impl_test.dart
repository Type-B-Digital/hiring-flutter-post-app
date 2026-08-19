import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/features/auth/data/auth_local_data_source.dart';
import 'package:postsapp/features/auth/data/auth_remote_data_source.dart';
import 'package:postsapp/features/auth/data/auth_repository_implement.dart';
import 'package:postsapp/features/auth/domain/user_model.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepositoryImplement repository;
  late UserModel testUser;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImplement(
      authRemoteDataSource: mockRemoteDataSource,
      authLocalDataSource: mockLocalDataSource,
    );
    testUser = const UserModel(
      id: 1,
      username: 'emilys',
      email: 'emily.johnson@x.dummyjson.com',
      accessToken: 'fake-access-token',
    );
  });

  group('login', () {
    test(
      'returns Success<UserModel> and saves token+user locally when login succeeds',
      () async {
        when(
          () => mockRemoteDataSource.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUser);
        when(
          () => mockLocalDataSource.saveToken(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.saveUser(any()),
        ).thenAnswer((_) async {});

        final result = await repository.login(
          username: 'emilys',
          password: 'emilyspass',
        );

        expect(result, isA<Success<UserModel>>());
        expect((result as Success<UserModel>).data, testUser);
        verify(
          () => mockLocalDataSource.saveToken(testUser.accessToken),
        ).called(1);
        verify(() => mockLocalDataSource.saveUser(testUser)).called(1);
      },
    );

    test(
      'returns Error<InvalidCredentialsFailure> when remote throws DioException with 400',
      () async {
        when(
          () => mockRemoteDataSource.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/login'),
              statusCode: 400,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await repository.login(
          username: 'emilys',
          password: 'wrongpass',
        );

        expect(result, isA<Error<UserModel>>());
        expect(
          (result as Error<UserModel>).failure,
          isA<InvalidCredentialsFailure>(),
        );
        verifyNever(() => mockLocalDataSource.saveToken(any()));
      },
    );

    test(
      'returns Error<NetworkFailure> when remote throws a connection error',
      () async {
        when(
          () => mockRemoteDataSource.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await repository.login(
          username: 'emilys',
          password: 'emilyspass',
        );

        expect(result, isA<Error<UserModel>>());
        expect((result as Error<UserModel>).failure, isA<NetworkFailure>());
      },
    );

    test(
      'returns Error<ServerFailure> when remote response is malformed',
      () async {
        when(
          () => mockRemoteDataSource.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const FormatException('Invalid login response'));

        final result = await repository.login(
          username: 'emilys',
          password: 'emilyspass',
        );

        expect(result, isA<Error<UserModel>>());
        expect((result as Error<UserModel>).failure, isA<ServerFailure>());
      },
    );
  });

  group('restoreSession', () {
    test('returns null when no token is stored', () async {
      when(() => mockLocalDataSource.getToken()).thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      expect(result, isNull);
      verifyNever(() => mockRemoteDataSource.getCurrentUser());
    });

    test('returns UserModel when a valid token exists', () async {
      when(
        () => mockLocalDataSource.getToken(),
      ).thenAnswer((_) async => 'valid-token');
      when(
        () => mockRemoteDataSource.getCurrentUser(),
      ).thenAnswer((_) async => testUser);

      final result = await repository.restoreSession();

      expect(result, testUser);
    });

    test(
      'clears local storage and returns null when token is rejected with 401',
      () async {
        when(
          () => mockLocalDataSource.getToken(),
        ).thenAnswer((_) async => 'expired-token');
        when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/me'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/me'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        when(() => mockLocalDataSource.clearAll()).thenAnswer((_) async {});

        final result = await repository.restoreSession();

        expect(result, isNull);
        verify(() => mockLocalDataSource.clearAll()).called(1);
      },
    );
  });

  group('logout', () {
    test('clears local storage when logout is called', () async {
      when(() => mockLocalDataSource.clearAll()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockLocalDataSource.clearAll()).called(1);
    });
  });
}
