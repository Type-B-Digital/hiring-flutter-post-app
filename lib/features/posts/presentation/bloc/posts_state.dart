import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

enum PostsStatus { initial, success, failure }

class PostsState extends Equatable {
  final PostsStatus status;
  final List<Post> posts;
  final bool hasReachedMax;
  final String errorMessage;
  final String searchQuery;

  const PostsState({
    this.status = PostsStatus.initial,
    this.posts = const <Post>[],
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.searchQuery = '',
  });

  PostsState copyWith({
    PostsStatus? status,
    List<Post>? posts,
    bool? hasReachedMax,
    String? errorMessage,
    String? searchQuery,
  }) {
    return PostsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props =>
      [status, posts, hasReachedMax, errorMessage, searchQuery];
}
