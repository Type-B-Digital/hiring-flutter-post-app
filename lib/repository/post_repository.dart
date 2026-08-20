import 'package:dio/dio.dart';
import 'package:post_app/models/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts({required int skip, required int limit});
  Future<List<Post>> searchPosts({required String query, required int skip, required int limit});
}

class PostRepositoryImpl implements PostRepository {
  final Dio _dio;

  PostRepositoryImpl(this._dio);

  @override
  Future<List<Post>> getPosts({required int skip, required int limit}) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['posts'] as List).map((p) => Post.fromJson(p as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      throw Exception('Failed to load posts. Please try again.');
    }
  }

  @override
  Future<List<Post>> searchPosts({
    required String query,
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await _dio.get(
        '/posts/search',
        queryParameters: {'q': query, 'skip': skip, 'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      return (data['posts'] as List).map((p) => Post.fromJson(p as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      throw Exception('Failed to search posts. Please try again.');
    }
  }
}
