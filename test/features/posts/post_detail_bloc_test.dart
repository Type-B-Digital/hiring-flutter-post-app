import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/core/error/failures.dart';
import 'package:posts_app/core/utils/either.dart';
import 'package:posts_app/features/posts/domain/entities/post.dart';
import 'package:posts_app/features/posts/domain/repositories/posts_repository.dart';
import 'package:posts_app/features/posts/presentation/bloc/post_detail_bloc.dart';
import 'package:posts_app/features/posts/presentation/bloc/post_detail_event.dart';
import 'package:posts_app/features/posts/presentation/bloc/post_detail_state.dart';

class MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late MockPostsRepository mockPostsRepository;

  const tInitialPost = Post(
    id: 1,
    title: 'Cached Title',
    body: 'Cached Body',
    tags: ['tag'],
    reactions: 1,
    views: 1,
    userId: 1,
  );

  const tFreshPost = Post(
    id: 1,
    title: 'Fresh Title',
    body: 'Fresh Body',
    tags: ['tag'],
    reactions: 10,
    views: 100,
    userId: 1,
  );

  setUp(() {
    mockPostsRepository = MockPostsRepository();
  });

  test('initialState_holdsInitialPostWithStatusInitial', () {
    final bloc = PostDetailBloc(
        postsRepository: mockPostsRepository, initialPost: tInitialPost);
    expect(bloc.state, const PostDetailState(post: tInitialPost));
    bloc.close();
  });

  blocTest<PostDetailBloc, PostDetailState>(
    'PostDetailFetched_onSuccess_emitsLoadingThenFreshPost',
    build: () {
      when(() => mockPostsRepository.getPostById(1))
          .thenAnswer((_) async => const Right(tFreshPost));
      return PostDetailBloc(
          postsRepository: mockPostsRepository, initialPost: tInitialPost);
    },
    act: (bloc) => bloc.add(const PostDetailFetched(1)),
    expect: () => [
      const PostDetailState(
          status: PostDetailStatus.loading, post: tInitialPost),
      const PostDetailState(status: PostDetailStatus.success, post: tFreshPost),
    ],
  );

  blocTest<PostDetailBloc, PostDetailState>(
    'PostDetailFetched_onFailure_emitsFailureButKeepsCachedPost',
    build: () {
      when(() => mockPostsRepository.getPostById(1))
          .thenAnswer((_) async => const Left(NetworkFailure()));
      return PostDetailBloc(
          postsRepository: mockPostsRepository, initialPost: tInitialPost);
    },
    act: (bloc) => bloc.add(const PostDetailFetched(1)),
    expect: () => [
      const PostDetailState(
          status: PostDetailStatus.loading, post: tInitialPost),
      const PostDetailState(
        status: PostDetailStatus.failure,
        post: tInitialPost,
        errorMessage: 'No internet connection',
      ),
    ],
  );
}
