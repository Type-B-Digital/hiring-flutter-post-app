import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;

  PostsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResponse<Post>>> getPosts(
      int skip, int limit) async {
    try {
      final response = await remoteDataSource.getPosts(skip, limit);
      return Right(PaginatedResponse<Post>(
        items: response.items,
        total: response.total,
        skip: response.skip,
        limit: response.limit,
      ));
    } on DioException catch (e) {
      if (e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure());
      }
      return const Left(ServerFailure());
    } on SocketException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<Post>>> searchPosts(
      String query, int skip, int limit) async {
    try {
      final response = await remoteDataSource.searchPosts(query, skip, limit);
      return Right(PaginatedResponse<Post>(
        items: response.items,
        total: response.total,
        skip: response.skip,
        limit: response.limit,
      ));
    } on DioException catch (e) {
      if (e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure());
      }
      return const Left(ServerFailure());
    } on SocketException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    try {
      final post = await remoteDataSource.getPostById(id);
      return Right(post);
    } on DioException catch (e) {
      if (e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure());
      }
      return const Left(ServerFailure());
    } on SocketException {
      return const Left(NetworkFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
