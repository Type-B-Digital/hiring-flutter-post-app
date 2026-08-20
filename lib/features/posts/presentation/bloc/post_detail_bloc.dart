import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import 'post_detail_event.dart';
import 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final PostsRepository postsRepository;

  PostDetailBloc({required this.postsRepository, required Post initialPost})
      : super(PostDetailState(post: initialPost)) {
    on<PostDetailFetched>(_onPostDetailFetched);
  }

  Future<void> _onPostDetailFetched(
    PostDetailFetched event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(state.copyWith(status: PostDetailStatus.loading));
    final result = await postsRepository.getPostById(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PostDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (post) => emit(state.copyWith(
        status: PostDetailStatus.success,
        post: post,
      )),
    );
  }
}
