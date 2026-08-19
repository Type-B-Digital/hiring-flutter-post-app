import 'package:postsapp/core/network/api_client.dart';
import 'package:postsapp/features/posts/domain/post_model.dart';

class PostsRemoteDataSource {
  final ApiClient apiClient;

  PostsRemoteDataSource(this.apiClient);

  Future<PostsResponseModel> getPosts({
    required int limit,
    required int skip,
  }) async {
    final response = await apiClient.dio.get(
      '/posts',
      queryParameters: {'limit': limit, 'skip': skip},
    );

    //debugPrint('Posts: ${response.data}');

    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Invalid posts response');
    }
    return PostsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PostsResponseModel> searchPosts({
    required String query,
    required int limit,
    required int skip,
  }) async {
    final response = await apiClient.dio.get(
      '/posts/search',
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );

    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Invalid search response');
    }
    return PostsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PostModel> getPostById(int id) async {
    final response = await apiClient.dio.get('/posts/$id');

    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Invalid post response');
    }
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }
}
