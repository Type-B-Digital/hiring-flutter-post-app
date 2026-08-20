import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/core/error/failures.dart';
import 'package:posts_app/core/models/paginated_response.dart';
import 'package:posts_app/core/utils/either.dart';
import 'package:posts_app/features/posts/domain/entities/post.dart';
import 'package:posts_app/features/posts/domain/repositories/posts_repository.dart';
import 'package:posts_app/features/posts/presentation/bloc/posts_bloc.dart';
import 'package:posts_app/features/posts/presentation/bloc/posts_event.dart';
import 'package:posts_app/features/posts/presentation/bloc/posts_state.dart';

class MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late PostsBloc postsBloc;
  late MockPostsRepository mockPostsRepository;

  setUp(() {
    mockPostsRepository = MockPostsRepository();
    postsBloc = PostsBloc(postsRepository: mockPostsRepository);
  });

  tearDown(() {
    postsBloc.close();
  });

  const tPost = Post(
    id: 1,
    title: 'Test',
    body: 'Body',
    tags: ['tag'],
    reactions: 10,
    views: 100,
    userId: 1,
  );

  const tPost2 = Post(
    id: 2,
    title: 'Test 2',
    body: 'Body 2',
    tags: ['tag'],
    reactions: 5,
    views: 50,
    userId: 1,
  );

  final tFullPagePosts = List<Post>.generate(
    10,
    (i) => Post(
      id: i + 1,
      title: 'Test $i',
      body: 'Body $i',
      tags: const ['tag'],
      reactions: i,
      views: i * 10,
      userId: 1,
    ),
  );

  final tPaginatedResponse = PaginatedResponse<Post>(
    items: tFullPagePosts,
    total: 100,
    skip: 0,
    limit: 10,
  );

  final tSecondPagePosts = List<Post>.generate(
    10,
    (i) => Post(
      id: 100 + i,
      title: 'Page2 $i',
      body: 'Body $i',
      tags: const ['tag'],
      reactions: i,
      views: i * 10,
      userId: 1,
    ),
  );

  group('PostsBloc', () {
    test('initial state is PostsStatus.initial', () {
      expect(postsBloc.state.status, PostsStatus.initial);
    });

    blocTest<PostsBloc, PostsState>(
      'PostsFetched_onSuccess_emitsSuccessWithPosts',
      build: () {
        when(() => mockPostsRepository.getPosts(any(), any()))
            .thenAnswer((_) async => Right(tPaginatedResponse));
        return postsBloc;
      },
      act: (bloc) => bloc.add(PostsFetched()),
      expect: () => [
        PostsState(
          status: PostsStatus.success,
          posts: tFullPagePosts,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'PostsFetched_onFailure_emitsFailure',
      build: () {
        when(() => mockPostsRepository.getPosts(any(), any()))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return postsBloc;
      },
      act: (bloc) => bloc.add(PostsFetched()),
      expect: () => [
        const PostsState(
          status: PostsStatus.failure,
          errorMessage: 'A server error occurred',
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'PostsFetched_whenAlreadyHasReachedMax_emitsNothing',
      build: () => postsBloc,
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [tPost],
        hasReachedMax: true,
      ),
      act: (bloc) => bloc.add(PostsFetched()),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockPostsRepository.getPosts(any(), any()));
      },
    );

    blocTest<PostsBloc, PostsState>(
      'PostsFetched_whenAlreadyHasPosts_appendsNextPage',
      build: () {
        when(() => mockPostsRepository.getPosts(1, 10)).thenAnswer(
          (_) async => Right(
            PaginatedResponse<Post>(
                items: tSecondPagePosts, total: 100, skip: 1, limit: 10),
          ),
        );
        return postsBloc;
      },
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [tPost],
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(PostsFetched()),
      expect: () => [
        PostsState(
          status: PostsStatus.success,
          posts: [tPost, ...tSecondPagePosts],
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'PostsFetched_whenNextPageReturnsFewerThanLimit_setsHasReachedMax',
      build: () {
        when(() => mockPostsRepository.getPosts(1, 10)).thenAnswer(
          (_) async => const Right(
            PaginatedResponse<Post>(
                items: [tPost2], total: 2, skip: 1, limit: 10),
          ),
        );
        return postsBloc;
      },
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [tPost],
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(PostsFetched()),
      expect: () => [
        const PostsState(
          status: PostsStatus.success,
          posts: [tPost, tPost2],
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'PostsFetched_whenNextPageIsEmpty_setsHasReachedMaxWithoutChangingPosts',
      build: () {
        when(() => mockPostsRepository.getPosts(1, 10)).thenAnswer(
          (_) async => const Right(
            PaginatedResponse<Post>(items: [], total: 1, skip: 1, limit: 10),
          ),
        );
        return postsBloc;
      },
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [tPost],
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(PostsFetched()),
      expect: () => [
        const PostsState(
          status: PostsStatus.success,
          posts: [tPost],
          hasReachedMax: true,
        ),
      ],
    );
  });

  group('PostsRefreshed', () {
    blocTest<PostsBloc, PostsState>(
      'PostsRefreshed_withNoSearchQuery_resetsAndFetchesFirstPage',
      build: () {
        when(() => mockPostsRepository.getPosts(0, 10))
            .thenAnswer((_) async => Right(tPaginatedResponse));
        return postsBloc;
      },
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [tPost2],
        hasReachedMax: true,
      ),
      act: (bloc) => bloc.add(PostsRefreshed()),
      expect: () => [
        const PostsState(
            status: PostsStatus.initial, posts: [], hasReachedMax: false),
        PostsState(
            status: PostsStatus.success,
            posts: tFullPagePosts,
            hasReachedMax: false),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'PostsRefreshed_withActiveSearchQuery_refreshesSearchResults',
      build: () {
        when(() => mockPostsRepository.searchPosts('love', 0, 10))
            .thenAnswer((_) async => Right(tPaginatedResponse));
        return postsBloc;
      },
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [tPost2],
        hasReachedMax: true,
        searchQuery: 'love',
      ),
      act: (bloc) => bloc.add(PostsRefreshed()),
      expect: () => [
        const PostsState(
          status: PostsStatus.initial,
          posts: [],
          hasReachedMax: false,
          searchQuery: 'love',
        ),
        PostsState(
          status: PostsStatus.success,
          posts: tFullPagePosts,
          hasReachedMax: false,
          searchQuery: 'love',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockPostsRepository.getPosts(any(), any()));
      },
    );

    blocTest<PostsBloc, PostsState>(
      'PostsRefreshed_onFailure_emitsFailureState',
      build: () {
        when(() => mockPostsRepository.getPosts(0, 10))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return postsBloc;
      },
      act: (bloc) => bloc.add(PostsRefreshed()),
      expect: () => [
        const PostsState(
            status: PostsStatus.initial, posts: [], hasReachedMax: false),
        const PostsState(
          status: PostsStatus.failure,
          errorMessage: 'No internet connection',
        ),
      ],
    );
  });

  group('PostsSearchQueryChanged', () {
    blocTest<PostsBloc, PostsState>(
      'PostsSearchQueryChanged_debouncesRapidInput_onlySearchesFinalQuery',
      build: () {
        when(() => mockPostsRepository.searchPosts('love', 0, 10))
            .thenAnswer((_) async => Right(tPaginatedResponse));
        return postsBloc;
      },
      act: (bloc) {
        bloc.add(const PostsSearchQueryChanged('l'));
        bloc.add(const PostsSearchQueryChanged('lo'));
        bloc.add(const PostsSearchQueryChanged('love'));
      },
      wait: const Duration(milliseconds: 350),
      expect: () => [
        const PostsState(
          status: PostsStatus.initial,
          posts: [],
          hasReachedMax: false,
          searchQuery: 'love',
        ),
        PostsState(
          status: PostsStatus.success,
          posts: tFullPagePosts,
          hasReachedMax: false,
          searchQuery: 'love',
        ),
      ],
      verify: (_) {
        verifyNever(() => mockPostsRepository.searchPosts('l', any(), any()));
        verifyNever(() => mockPostsRepository.searchPosts('lo', any(), any()));
      },
    );

    blocTest<PostsBloc, PostsState>(
      'PostsSearchQueryChanged_withEmptyQuery_fallsBackToPostsFetched',
      build: () {
        when(() => mockPostsRepository.getPosts(0, 10))
            .thenAnswer((_) async => Right(tPaginatedResponse));
        return postsBloc;
      },
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [tPost2],
        hasReachedMax: true,
        searchQuery: 'love',
      ),
      act: (bloc) => bloc.add(const PostsSearchQueryChanged('')),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        const PostsState(
            status: PostsStatus.initial, posts: [], hasReachedMax: false),
        PostsState(
            status: PostsStatus.success,
            posts: tFullPagePosts,
            hasReachedMax: false),
      ],
      verify: (_) {
        verifyNever(() => mockPostsRepository.searchPosts(any(), any(), any()));
      },
    );

    blocTest<PostsBloc, PostsState>(
      'PostsSearchQueryChanged_withNoMatches_emitsEmptySuccessState',
      build: () {
        when(() => mockPostsRepository.searchPosts('zzz', 0, 10)).thenAnswer(
          (_) async => const Right(
            PaginatedResponse<Post>(items: [], total: 0, skip: 0, limit: 10),
          ),
        );
        return postsBloc;
      },
      act: (bloc) => bloc.add(const PostsSearchQueryChanged('zzz')),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        const PostsState(
          status: PostsStatus.initial,
          posts: [],
          hasReachedMax: false,
          searchQuery: 'zzz',
        ),
        const PostsState(
          status: PostsStatus.success,
          posts: [],
          hasReachedMax: true,
          searchQuery: 'zzz',
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'PostsSearchQueryChanged_onFailure_emitsFailureState',
      build: () {
        when(() => mockPostsRepository.searchPosts('love', 0, 10))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return postsBloc;
      },
      act: (bloc) => bloc.add(const PostsSearchQueryChanged('love')),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        const PostsState(
          status: PostsStatus.initial,
          posts: [],
          hasReachedMax: false,
          searchQuery: 'love',
        ),
        const PostsState(
          status: PostsStatus.failure,
          errorMessage: 'A server error occurred',
          searchQuery: 'love',
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'PostsSearchQueryChanged_withSameQueryAsCurrent_emitsNothing',
      build: () => postsBloc,
      seed: () => const PostsState(searchQuery: 'love'),
      act: (bloc) => bloc.add(const PostsSearchQueryChanged('love')),
      wait: const Duration(milliseconds: 350),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockPostsRepository.searchPosts(any(), any(), any()));
      },
    );
  });
}
