import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/core/network/dio_client.dart';
import 'package:posts_app/features/posts/data/datasources/posts_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

Response<dynamic> _postsEnvelopeResponse(String path) => Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {
        'posts': [
          {
            'id': 1,
            'title': 'Title',
            'body': 'Body',
            'tags': [],
            'reactions': 0,
            'views': 0,
            'userId': 1,
          }
        ],
        'total': 1,
        'skip': 0,
        'limit': 10,
      },
    );

void _stubPostsAndUsersEndpoints(MockDio mockDio) {
  when(() => mockDio.get(any())).thenAnswer((invocation) async {
    final path = invocation.positionalArguments[0] as String;
    if (path.startsWith('/users/')) {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: {'username': 'johnd'},
      );
    }
    return _postsEnvelopeResponse(path);
  });
}

void main() {
  late MockDio mockDio;
  late PostsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    final dioClient = DioClient(MockFlutterSecureStorage(), dio: mockDio);
    dataSource = PostsRemoteDataSourceImpl(dioClient);
  });

  group('getPosts', () {
    test('getPosts_buildsRequestWithSkipAndLimitQueryParams', () async {
      _stubPostsAndUsersEndpoints(mockDio);

      await dataSource.getPosts(20, 10);

      verify(() => mockDio.get('/posts?skip=20&limit=10')).called(1);
    });
  });

  group('searchPosts', () {
    test('searchPosts_buildsRequestWithQueryAndPaginationParams', () async {
      _stubPostsAndUsersEndpoints(mockDio);

      await dataSource.searchPosts('love', 10, 15);

      verify(() => mockDio.get('/posts/search?q=love&skip=10&limit=15'))
          .called(1);
    });
  });

  group('getPostById', () {
    test('getPostById_requestsSinglePostByIdAndPopulatesAuthor', () async {
      when(() => mockDio.get(any())).thenAnswer((invocation) async {
        final path = invocation.positionalArguments[0] as String;
        if (path == '/posts/1') {
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: {
              'id': 1,
              'title': 'Title',
              'body': 'Body',
              'tags': [],
              'reactions': 0,
              'views': 0,
              'userId': 1,
            },
          );
        }
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {'username': 'johnd'},
        );
      });

      final result = await dataSource.getPostById(1);

      expect(result.id, 1);
      expect(result.authorName, 'johnd');
      verify(() => mockDio.get('/posts/1')).called(1);
    });
  });
}
