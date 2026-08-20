import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

enum PostDetailStatus { initial, loading, success, failure }

class PostDetailState extends Equatable {
  final PostDetailStatus status;
  final Post post;
  final String errorMessage;

  const PostDetailState({
    this.status = PostDetailStatus.initial,
    required this.post,
    this.errorMessage = '',
  });

  PostDetailState copyWith({
    PostDetailStatus? status,
    Post? post,
    String? errorMessage,
  }) {
    return PostDetailState(
      status: status ?? this.status,
      post: post ?? this.post,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, post, errorMessage];
}
