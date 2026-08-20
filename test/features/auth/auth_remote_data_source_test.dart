import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/core/network/dio_client.dart';
import 'package:posts_app/features/auth/data/datasources/auth_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockDio mockDio;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    final dioClient = DioClient(MockFlutterSecureStorage(), dio: mockDio);
    dataSource = AuthRemoteDataSourceImpl(dioClient);
  });

  Response<dynamic> userResponse(String path) => Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {
          'id': 1,
          'username': 'emilys',
          'email': 'emily.johnson@x.dummyjson.com',
          'firstName': 'Emily',
          'lastName': 'Johnson',
          'image': 'https://dummyjson.com/icon/emilys/128',
          'accessToken': 'accessToken123',
        },
      );

  group('login', () {
    test('login_postsUsernamePasswordAndExpiresInMinsToAuthLoginPath',
        () async {
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((invocation) async => userResponse('/auth/login'));

      await dataSource.login('emilys', 'emilyspass');

      verify(() => mockDio.post(
            '/auth/login',
            data: {
              'username': 'emilys',
              'password': 'emilyspass',
              'expiresInMins': 60,
            },
          )).called(1);
    });
  });

  group('getCurrentUser', () {
    test('getCurrentUser_getsAuthMePath', () async {
      when(() => mockDio.get('/auth/me'))
          .thenAnswer((_) async => userResponse('/auth/me'));

      final result = await dataSource.getCurrentUser();

      expect(result.username, 'emilys');
      verify(() => mockDio.get('/auth/me')).called(1);
    });
  });
}
