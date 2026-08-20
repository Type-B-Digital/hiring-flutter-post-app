import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/post.dart';

abstract class PostsRepository {
  Future<Either<Failure, PaginatedResponse<Post>>> getPosts(
      int skip, int limit);
  Future<Either<Failure, PaginatedResponse<Post>>> searchPosts(
      String query, int skip, int limit);
  Future<Either<Failure, Post>> getPostById(int id);
}
