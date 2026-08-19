import 'package:postsapp/core/error/result.dart';
import 'post_model.dart';

abstract class PostsRepository {
  Future<Result<PostsResponseModel>> getPosts({
    required int limit,
    required int skip,
  });

  Future<Result<PostsResponseModel>> searchPosts({
    required String query,
    required int limit,
    required int skip,
  });

  Future<Result<PostModel>> getPostById(int id);
}
