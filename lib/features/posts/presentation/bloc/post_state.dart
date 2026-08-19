part of 'post_bloc.dart';

@immutable
sealed class PostState {}

final class PostInitial extends PostState {}

class PostsInitial extends PostState {}

class PostsLoading extends PostState {}

class PostsLoadedState extends PostState {
  final List<PostModel> posts;
  final int total;
  final int skip;
  final int limit;
  final String query;
  final bool isLoadingMore;

  PostsLoadedState({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
    this.query = '',
    this.isLoadingMore = false,
  });

  bool get hasReachedEnd => skip + limit >= total;

  PostsLoadedState copyWith({
    List<PostModel>? posts,
    int? total,
    int? skip,
    int? limit,
    String? query,
    bool? isLoadingMore,
  }) {
    return PostsLoadedState(
      posts: posts ?? this.posts,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      query: query ?? this.query,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class PostsEmpty extends PostState {}

class PostsError extends PostState {
  final Failure failure;
  PostsError(this.failure);
}
