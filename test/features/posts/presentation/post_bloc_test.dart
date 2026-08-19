import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/features/posts/domain/post_model.dart';
import 'package:postsapp/features/posts/domain/post_repository.dart';
import 'package:postsapp/features/posts/presentation/bloc/post_bloc.dart';

class MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late MockPostsRepository mockPostsRepository;
  late PostModel testPost;

  setUp(() {
    mockPostsRepository = MockPostsRepository();
    testPost = const PostModel(
      id: 1,
      title: 'Test title',
      body: 'Test body',
      userId: 1,
      tags: ['test'],
      reactions: Reactions(likes: 5, dislikes: 1),
      views: 50,
    );
  });

  group('PostsFetchRequestedEvent', () {
    blocTest<PostBloc, PostState>(
      'emits [PostsLoading, PostsLoadedState] when fetch succeeds with posts',
      build: () {
        when(
          () => mockPostsRepository.getPosts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PostsResponseModel(posts: [testPost], total: 1, skip: 0, limit: 10),
          ),
        );
        return PostBloc(mockPostsRepository);
      },
      act: (bloc) => bloc.add(PostsFetchRequestedEvent()),
      expect: () => [
        isA<PostsLoading>(),
        isA<PostsLoadedState>()
            .having((s) => s.posts.length, 'posts.length', 1)
            .having((s) => s.hasReachedEnd, 'hasReachedEnd', true),
      ],
    );

    blocTest<PostBloc, PostState>(
      'emits [PostsLoading, PostsEmpty] when fetch returns zero posts',
      build: () {
        when(
          () => mockPostsRepository.getPosts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenAnswer(
          (_) async => const Result.success(
            PostsResponseModel(posts: [], total: 0, skip: 0, limit: 10),
          ),
        );
        return PostBloc(mockPostsRepository);
      },
      act: (bloc) => bloc.add(PostsFetchRequestedEvent()),
      expect: () => [isA<PostsLoading>(), isA<PostsEmpty>()],
    );

    blocTest<PostBloc, PostState>(
      'emits [PostsLoading, PostsError] when fetch fails',
      build: () {
        when(
          () => mockPostsRepository.getPosts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenAnswer((_) async => Result.failure(const NetworkFailure()));
        return PostBloc(mockPostsRepository);
      },
      act: (bloc) => bloc.add(PostsFetchRequestedEvent()),
      expect: () => [
        isA<PostsLoading>(),
        isA<PostsError>().having(
          (s) => s.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      ],
    );
  });

  group('PostsNextPageRequestedEvent', () {
    blocTest<PostBloc, PostState>(
      'appends posts and updates skip when next page succeeds',
      build: () {
        when(
          () => mockPostsRepository.getPosts(
            limit: any(named: 'limit'),
            skip: 10,
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PostsResponseModel(
              posts: [
                const PostModel(
                  id: 2,
                  title: 'Second post',
                  body: 'Body',
                  userId: 2,
                  tags: [],
                  reactions: Reactions(likes: 0, dislikes: 0),
                  views: 1,
                ),
              ],
              total: 20,
              skip: 10,
              limit: 10,
            ),
          ),
        );
        return PostBloc(mockPostsRepository);
      },
      seed: () =>
          PostsLoadedState(posts: [testPost], total: 20, skip: 0, limit: 10),
      act: (bloc) => bloc.add(PostsNextPageRequestedEvent()),
      expect: () => [
        isA<PostsLoadedState>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          true,
        ),
        isA<PostsLoadedState>()
            .having((s) => s.posts.length, 'posts.length', 2)
            .having((s) => s.skip, 'skip', 10)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false),
      ],
    );

    blocTest<PostBloc, PostState>(
      'does not request next page when hasReachedEnd is true',
      build: () => PostBloc(mockPostsRepository),
      seed: () =>
          PostsLoadedState(posts: [testPost], total: 1, skip: 0, limit: 10),
      act: (bloc) => bloc.add(PostsNextPageRequestedEvent()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockPostsRepository.getPosts(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        );
      },
    );
  });

  group('PostsSearchChangedEvent', () {
    blocTest<PostBloc, PostState>(
      'debounces rapid search input and only fires once with the last query',
      build: () {
        when(
          () => mockPostsRepository.searchPosts(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PostsResponseModel(posts: [testPost], total: 1, skip: 0, limit: 10),
          ),
        );
        return PostBloc(mockPostsRepository);
      },
      act: (bloc) async {
        bloc.add(PostsSearchChangedEvent('f'));
        bloc.add(PostsSearchChangedEvent('fl'));
        bloc.add(PostsSearchChangedEvent('flu'));
      },
      wait: const Duration(milliseconds: 500),
      expect: () => [isA<PostsLoading>(), isA<PostsLoadedState>()],
      verify: (_) {
        verify(
          () => mockPostsRepository.searchPosts(
            query: 'flu',
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).called(1);
        verifyNever(
          () => mockPostsRepository.searchPosts(
            query: 'f',
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        );
      },
    );
  });
}
