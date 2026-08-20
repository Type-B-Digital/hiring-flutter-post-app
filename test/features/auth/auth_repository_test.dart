import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/core/error/failures.dart';
import 'package:posts_app/core/utils/either.dart';
import 'package:posts_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:posts_app/features/auth/data/models/user_model.dart';
import 'package:posts_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorage = MockFlutterSecureStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      secureStorage: mockSecureStorage,
    );
  });

  const tUserModel = UserModel(
    id: 1,
    username: 'test',
    email: 'test@test.com',
    firstName: 'Test',
    lastName: 'User',
    image: 'image.png',
    token: 'token123',
  );

  group('login', () {
    test('login_withValidCredentials_returnsUserAndStoresToken', () async {
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => tUserModel);
      when(() => mockSecureStorage.write(
          key: 'jwt_token',
          value: any(named: 'value'))).thenAnswer((_) async {});

      final result = await repository.login('test', 'password');

      expect(result, const Right(tUserModel));
      verify(() => mockSecureStorage.write(key: 'jwt_token', value: 'token123'))
          .called(1);
    });

    test('login_withInvalidCredentials_returnsAuthFailure', () async {
      when(() => mockRemoteDataSource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
              requestOptions: RequestOptions(path: ''), statusCode: 400),
        ),
      );

      final result = await repository.login('test', 'wrong');

      expect(result, const Left(AuthFailure('Invalid username or password.')));
    });

    test('login_onNetworkError_returnsNetworkFailure', () async {
      when(() => mockRemoteDataSource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.login('test', 'wrong');

      expect(result, const Left(NetworkFailure()));
    });

    test('login_onServerError_returnsServerFailure', () async {
      when(() => mockRemoteDataSource.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
              requestOptions: RequestOptions(path: ''), statusCode: 500),
        ),
      );

      final result = await repository.login('test', 'wrong');

      expect(result, const Left(ServerFailure()));
    });
  });

  group('getCurrentUser', () {
    test('getCurrentUser_whenTokenExists_returnsUser', () async {
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => 'token123');
      when(() => mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserModel);

      final result = await repository.getCurrentUser();

      expect(result, const Right(tUserModel));
    });

    test('getCurrentUser_whenTokenDoesNotExist_returnsAuthFailure', () async {
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result, const Left(AuthFailure('No token found')));
      verifyNever(() => mockRemoteDataSource.getCurrentUser());
    });

    test('getCurrentUser_onNetworkError_returnsNetworkFailure', () async {
      when(() => mockSecureStorage.read(key: 'jwt_token'))
          .thenAnswer((_) async => 'token123');
      when(() => mockRemoteDataSource.getCurrentUser()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.getCurrentUser();

      expect(result, const Left(NetworkFailure()));
    });
  });

  group('logout', () {
    test('logout_deletesStoredToken', () async {
      when(() => mockSecureStorage.delete(key: 'jwt_token'))
          .thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockSecureStorage.delete(key: 'jwt_token')).called(1);
    });
  });
}
