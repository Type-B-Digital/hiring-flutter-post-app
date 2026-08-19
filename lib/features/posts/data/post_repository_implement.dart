import 'package:dio/dio.dart';
import 'package:postsapp/core/error/exception_mapper.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/features/posts/data/post_remote_data_source.dart';
import 'package:postsapp/features/posts/domain/post_model.dart';
import 'package:postsapp/features/posts/domain/post_repository.dart';

class PostsRepositoryImplement implements PostsRepository {
  final PostsRemoteDataSource postsRemoteDataSource;

  PostsRepositoryImplement(this.postsRemoteDataSource);

  @override
  Future<Result<PostsResponseModel>> getPosts({
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await postsRemoteDataSource.getPosts(
        limit: limit,
        skip: skip,
      );
      return Result.success(response);
    } on DioException catch (e) {
      return Result.failure(mapDioExceptionToFailure(e));
    } on FormatException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (_) {
      return Result.failure(const UnknownFailure());
    }
  }

  @override
  Future<Result<PostsResponseModel>> searchPosts({
    required String query,
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await postsRemoteDataSource.searchPosts(
        query: query,
        limit: limit,
        skip: skip,
      );
      return Result.success(response);
    } on DioException catch (e) {
      return Result.failure(mapDioExceptionToFailure(e));
    } on FormatException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (_) {
      return Result.failure(const UnknownFailure());
    }
  }

  @override
  Future<Result<PostModel>> getPostById(int id) async {
    try {
      final post = await postsRemoteDataSource.getPostById(id);
      return Result.success(post);
    } on DioException catch (e) {
      return Result.failure(mapDioExceptionToFailure(e));
    } on FormatException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (_) {
      return Result.failure(const UnknownFailure());
    }
  }
}
