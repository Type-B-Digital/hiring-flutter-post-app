import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/core/utils/debouncer.dart';
import 'package:postsapp/features/posts/domain/post_model.dart';
import 'package:postsapp/features/posts/domain/post_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const int _pageSize = 10;
const Duration _searchDebounceTime = Duration(milliseconds: 400);

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostsRepository postsRepository;
  final Debouncer _debouncer = Debouncer();

  PostBloc(this.postsRepository) : super(PostInitial()) {
    on<PostsFetchRequestedEvent>(_onFetchRequested);
    on<PostsNextPageRequestedEvent>(_onNextPageRequested);
    on<PostsRefreshRequestedEvent>(_onRefreshRequested);
    on<PostsSearchChangedEvent>(
      _onSearchChanged,
      transformer: _debounce(_searchDebounceTime),
    );
  }

  Future<void> _onFetchRequested(
    PostsFetchRequestedEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostsLoading());
    final result = await postsRepository.getPosts(limit: _pageSize, skip: 0);
    _emitFromResult(result, emit, query: '');
  }

  void _emitFromResult(
    Result result,
    Emitter<PostState> emit, {
    required String query,
  }) {
    switch (result) {
      case Success(:final data):
        if (data.posts.isEmpty) {
          emit(PostsEmpty());
        } else {
          emit(
            PostsLoadedState(
              posts: data.posts,
              total: data.total,
              skip: data.skip,
              limit: data.limit,
              query: query,
            ),
          );
        }
      case Error(:final failure):
        emit(PostsError(failure));
    }
  }

  Future<void> _onNextPageRequested(
    PostsNextPageRequestedEvent event,
    Emitter<PostState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PostsLoadedState) return;
    if (currentState.hasReachedEnd || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextSkip = currentState.skip + currentState.limit;
    final result = currentState.query.isEmpty
        ? await postsRepository.getPosts(limit: _pageSize, skip: nextSkip)
        : await postsRepository.searchPosts(
            query: currentState.query,
            limit: _pageSize,
            skip: nextSkip,
          );

    switch (result) {
      case Success(:final data):
        emit(
          currentState.copyWith(
            posts: [...currentState.posts, ...data.posts],
            skip: data.skip,
            limit: data.limit,
            total: data.total,
            isLoadingMore: false,
          ),
        );
      case Error():
        emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefreshRequested(
    PostsRefreshRequestedEvent event,
    Emitter<PostState> emit,
  ) async {
    final query = _currentQuery(state);
    final result = query.isEmpty
        ? await postsRepository.getPosts(limit: _pageSize, skip: 0)
        : await postsRepository.searchPosts(
            query: query,
            limit: _pageSize,
            skip: 0,
          );
    _emitFromResult(result, emit, query: query);
  }

  Future<void> _onSearchChanged(
    PostsSearchChangedEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostsLoading());
    final result = event.query.isEmpty
        ? await postsRepository.getPosts(limit: _pageSize, skip: 0)
        : await postsRepository.searchPosts(
            query: event.query,
            limit: _pageSize,
            skip: 0,
          );
    _emitFromResult(result, emit, query: event.query);
  }

  String _currentQuery(PostState state) =>
      state is PostsLoadedState ? state.query : '';

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
