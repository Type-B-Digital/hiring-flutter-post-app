import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/core/error/failures.dart';
import 'package:posts_app/core/models/paginated_response.dart';
import 'package:posts_app/core/utils/either.dart';
import 'package:posts_app/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:posts_app/features/posts/data/models/post_model.dart';
import 'package:posts_app/features/posts/data/repositories/posts_repository_impl.dart';

class MockPostsRemoteDataSource extends Mock implements PostsRemoteDataSource {}

void main() {
  late PostsRepositoryImpl repository;
  late MockPostsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPostsRemoteDataSource();
    repository = PostsRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final tPostModelList = [
    const PostModel(
      id: 1,
      title: 'Test',
      body: 'Body',
      tags: ['tag'],
      reactions: 10,
      views: 100,
      userId: 1,
    )
  ];

  final tPaginatedResponse = PaginatedResponse<PostModel>(
    items: tPostModelList,
    total: 100,
    skip: 0,
    limit: 10,
  );

  group('getPosts', () {
    test('getPosts_onSuccess_returnsPaginatedResponse', () async {
      when(() => mockRemoteDataSource.getPosts(any(), any()))
          .thenAnswer((_) async => tPaginatedResponse);

      final result = await repository.getPosts(0, 10);

      expect(result.isRight, true);
    });

    test('getPosts_onNetworkError_returnsNetworkFailure', () async {
      when(() => mockRemoteDataSource.getPosts(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getPosts(0, 10);

      expect(result, const Left(NetworkFailure()));
    });

    test('getPosts_onServerError_returnsServerFailure', () async {
      when(() => mockRemoteDataSource.getPosts(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
              requestOptions: RequestOptions(path: ''), statusCode: 500),
        ),
      );

      final result = await repository.getPosts(0, 10);

      expect(result, const Left(ServerFailure()));
    });
  });

  group('searchPosts', () {
    test('searchPosts_onSuccess_returnsPaginatedResponse', () async {
      when(() => mockRemoteDataSource.searchPosts(any(), any(), any()))
          .thenAnswer((_) async => tPaginatedResponse);

      final result = await repository.searchPosts('love', 0, 10);

      expect(result.isRight, true);
      result.fold(
        (_) => fail('expected Right'),
        (response) => expect(response.items.length, 1),
      );
    });

    test('searchPosts_withNoMatches_returnsEmptyPaginatedResponse', () async {
      when(() => mockRemoteDataSource.searchPosts(any(), any(), any()))
          .thenAnswer(
        (_) async => const PaginatedResponse<PostModel>(
            items: [], total: 0, skip: 0, limit: 10),
      );

      final result = await repository.searchPosts('nomatch', 0, 10);

      expect(result.isRight, true);
      result.fold(
        (_) => fail('expected Right'),
        (response) => expect(response.items, isEmpty),
      );
    });

    test('searchPosts_onNetworkError_returnsNetworkFailure', () async {
      when(() => mockRemoteDataSource.searchPosts(any(), any(), any()))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.searchPosts('love', 0, 10);

      expect(result, const Left(NetworkFailure()));
    });
  });

  group('getPostById', () {
    test('getPostById_onSuccess_returnsPost', () async {
      when(() => mockRemoteDataSource.getPostById(any()))
          .thenAnswer((_) async => tPostModelList.first);

      final result = await repository.getPostById(1);

      expect(result.isRight, true);
      result.fold(
        (_) => fail('expected Right'),
        (post) => expect(post.id, 1),
      );
    });

    test('getPostById_onMalformedResponse_returnsServerFailure', () async {
      when(() => mockRemoteDataSource.getPostById(any())).thenThrow(
        const FormatException('Unexpected character'),
      );

      final result = await repository.getPostById(1);

      expect(result, const Left(ServerFailure()));
    });

    test('getPostById_onNetworkError_returnsNetworkFailure', () async {
      when(() => mockRemoteDataSource.getPostById(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.getPostById(1);

      expect(result, const Left(NetworkFailure()));
    });
  });
}
