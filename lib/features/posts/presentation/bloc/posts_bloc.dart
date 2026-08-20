import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/repositories/posts_repository.dart';
import 'posts_event.dart';
import 'posts_state.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.debounceTime(duration), mapper);
  };
}

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostsRepository postsRepository;

  PostsBloc({required this.postsRepository}) : super(const PostsState()) {
    on<PostsFetched>(
      _onPostsFetched,
      transformer: droppable(),
    );
    on<PostsRefreshed>(
      _onPostsRefreshed,
      transformer: droppable(),
    );
    on<PostsSearchQueryChanged>(
      _onPostsSearchQueryChanged,
      transformer: debounce(
        const Duration(milliseconds: AppConfig.searchDebounceMs),
      ),
    );
  }

  Future<void> _onPostsFetched(
    PostsFetched event,
    Emitter<PostsState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PostsStatus.initial) {
        final result =
            await postsRepository.getPosts(0, AppConfig.paginationLimit);
        return result.fold(
          (failure) => emit(state.copyWith(
            status: PostsStatus.failure,
            errorMessage: failure.message,
          )),
          (response) => emit(state.copyWith(
            status: PostsStatus.success,
            posts: response.items,
            hasReachedMax: response.items.length < AppConfig.paginationLimit,
          )),
        );
      }

      final result = await (state.searchQuery.isEmpty
          ? postsRepository.getPosts(
              state.posts.length, AppConfig.paginationLimit)
          : postsRepository.searchPosts(state.searchQuery, state.posts.length,
              AppConfig.paginationLimit));

      result.fold(
        (failure) => emit(state.copyWith(
          status: PostsStatus.failure,
          errorMessage: failure.message,
        )),
        (response) {
          emit(response.items.isEmpty
              ? state.copyWith(hasReachedMax: true)
              : state.copyWith(
                  status: PostsStatus.success,
                  posts: List.of(state.posts)..addAll(response.items),
                  hasReachedMax:
                      response.items.length < AppConfig.paginationLimit,
                ));
        },
      );
    } catch (_) {
      emit(state.copyWith(
          status: PostsStatus.failure, errorMessage: 'An error occurred'));
    }
  }

  Future<void> _onPostsRefreshed(
    PostsRefreshed event,
    Emitter<PostsState> emit,
  ) async {
    // Reset state for refresh but keep the query if there is one
    emit(state.copyWith(
        status: PostsStatus.initial, posts: [], hasReachedMax: false));
    final result = await (state.searchQuery.isEmpty
        ? postsRepository.getPosts(0, AppConfig.paginationLimit)
        : postsRepository.searchPosts(
            state.searchQuery, 0, AppConfig.paginationLimit));

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostsStatus.failure,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: PostsStatus.success,
        posts: response.items,
        hasReachedMax: response.items.length < AppConfig.paginationLimit,
      )),
    );
  }

  Future<void> _onPostsSearchQueryChanged(
    PostsSearchQueryChanged event,
    Emitter<PostsState> emit,
  ) async {
    if (event.query == state.searchQuery) return;

    emit(state.copyWith(
      status: PostsStatus.initial,
      posts: [],
      hasReachedMax: false,
      searchQuery: event.query,
    ));

    if (event.query.isEmpty) {
      add(PostsFetched());
      return;
    }

    final result = await postsRepository.searchPosts(
        event.query, 0, AppConfig.paginationLimit);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PostsStatus.failure,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: PostsStatus.success,
        posts: response.items,
        hasReachedMax: response.items.length < AppConfig.paginationLimit,
      )),
    );
  }
}
