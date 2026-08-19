import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/features/posts/data/post_remote_data_source.dart';
import 'package:postsapp/features/posts/data/post_repository_implement.dart';
import 'package:postsapp/features/posts/domain/post_model.dart';

class MockPostsRemoteDataSource extends Mock implements PostsRemoteDataSource {}

void main() {
  late MockPostsRemoteDataSource mockRemoteDataSource;
  late PostsRepositoryImplement repository;
  late PostModel testPost;
  late PostsResponseModel testResponse;

  setUp(() {
    mockRemoteDataSource = MockPostsRemoteDataSource();
    repository = PostsRepositoryImplement(mockRemoteDataSource);

    testPost = const PostModel(
      id: 1,
      title: 'Test title',
      body: 'Test body',
      userId: 1,
      tags: ['test', 'sample'],
      reactions: Reactions(likes: 10, dislikes: 2),
      views: 100,
    );

    testResponse = PostsResponseModel(
      posts: [testPost],
      total: 1,
      skip: 0,
      limit: 10,
    );
  });

  group('getPosts', () {
    test(
      'returns Success<PostsResponseModel> when getPosts succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getPosts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenAnswer((_) async => testResponse);

        final result = await repository.getPosts(limit: 10, skip: 0);

        expect(result, isA<Success<PostsResponseModel>>());
        expect((result as Success<PostsResponseModel>).data.posts.length, 1);
      },
    );

    test('returns Error<ServerFailure> when response is malformed', () async {
      when(
        () => mockRemoteDataSource.getPosts(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
        ),
      ).thenThrow(const FormatException('Invalid posts response'));

      final result = await repository.getPosts(limit: 10, skip: 0);

      expect(result, isA<Error<PostsResponseModel>>());
      expect(
        (result as Error<PostsResponseModel>).failure,
        isA<ServerFailure>(),
      );
    });

    test(
      'returns Error<NetworkFailure> when a connection error occurs',
      () async {
        when(
          () => mockRemoteDataSource.getPosts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/posts'),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await repository.getPosts(limit: 10, skip: 0);

        expect(result, isA<Error<PostsResponseModel>>());
        expect(
          (result as Error<PostsResponseModel>).failure,
          isA<NetworkFailure>(),
        );
      },
    );

    test(
      'returns Error<ServerFailure> when server responds with 5xx',
      () async {
        when(
          () => mockRemoteDataSource.getPosts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/posts'),
            response: Response(
              requestOptions: RequestOptions(path: '/posts'),
              statusCode: 500,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await repository.getPosts(limit: 10, skip: 0);

        expect(result, isA<Error<PostsResponseModel>>());
        expect(
          (result as Error<PostsResponseModel>).failure,
          isA<ServerFailure>(),
        );
      },
    );
  });

  group('searchPosts', () {
    test(
      'returns Success with empty posts and total 0 when no matches found',
      () async {
        when(
          () => mockRemoteDataSource.searchPosts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenAnswer(
          (_) async =>
              const PostsResponseModel(posts: [], total: 0, skip: 0, limit: 10),
        );

        final result = await repository.searchPosts(
          query: 'nonexistent',
          limit: 10,
          skip: 0,
        );

        expect(result, isA<Success<PostsResponseModel>>());
        final data = (result as Success<PostsResponseModel>).data;
        expect(data.posts, isEmpty);
        expect(data.total, 0);
      },
    );

    test(
      'returns Success<PostsResponseModel> when search succeeds with matches',
      () async {
        when(
          () => mockRemoteDataSource.searchPosts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenAnswer((_) async => testResponse);

        final result = await repository.searchPosts(
          query: 'test',
          limit: 10,
          skip: 0,
        );

        expect(result, isA<Success<PostsResponseModel>>());
        verify(
          () => mockRemoteDataSource.searchPosts(
            query: 'test',
            limit: 10,
            skip: 0,
          ),
        ).called(1);
      },
    );
  });

  group('getPostById', () {
    test('returns Success<PostModel> when getPostById succeeds', () async {
      when(
        () => mockRemoteDataSource.getPostById(any()),
      ).thenAnswer((_) async => testPost);

      final result = await repository.getPostById(1);

      expect(result, isA<Success<PostModel>>());
      expect((result as Success<PostModel>).data, testPost);
    });

    test('returns Error<ServerFailure> when getPostById throws 5xx', () async {
      when(() => mockRemoteDataSource.getPostById(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/posts/999'),
          response: Response(
            requestOptions: RequestOptions(path: '/posts/999'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getPostById(999);

      expect(result, isA<Error<PostModel>>());
      expect((result as Error<PostModel>).failure, isA<ServerFailure>());
    });
  });
}
