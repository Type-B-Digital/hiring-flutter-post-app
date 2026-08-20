import 'package:dio/dio.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<PaginatedResponse<PostModel>> getPosts(int skip, int limit);
  Future<PaginatedResponse<PostModel>> searchPosts(
      String query, int skip, int limit);
  Future<PostModel> getPostById(int id);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final DioClient dioClient;
  final Map<int, String> _userCache = {};

  PostsRemoteDataSourceImpl(this.dioClient);

  Future<PaginatedResponse<PostModel>> _populateUsers(
      PaginatedResponse<PostModel> response) async {
    final userIds = response.items.map((e) => e.userId).toSet();
    final missingUserIds = userIds.difference(_userCache.keys.toSet());

    if (missingUserIds.isNotEmpty) {
      await Future.wait(missingUserIds.map((id) async {
        try {
          final userRes = await dioClient.dio.get('/users/$id?select=username');
          if (userRes.statusCode == 200) {
            _userCache[id] = userRes.data['username'] as String;
          }
        } catch (e) {
          // ignore error
        }
      }));
    }

    final updatedItems = response.items.map((post) {
      return post.copyWith(authorName: _userCache[post.userId]);
    }).toList();

    return PaginatedResponse<PostModel>(
      items: updatedItems,
      total: response.total,
      skip: response.skip,
      limit: response.limit,
    );
  }

  @override
  Future<PaginatedResponse<PostModel>> getPosts(int skip, int limit) async {
    final response = await dioClient.dio.get('/posts?skip=$skip&limit=$limit');
    if (response.statusCode == 200) {
      final paginatedResponse = PaginatedResponse<PostModel>.fromJson(
        response.data,
        (json) => PostModel.fromJson(json),
        'posts',
      );
      return _populateUsers(paginatedResponse);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }

  @override
  Future<PaginatedResponse<PostModel>> searchPosts(
      String query, int skip, int limit) async {
    final response = await dioClient.dio
        .get('/posts/search?q=$query&skip=$skip&limit=$limit');
    if (response.statusCode == 200) {
      final paginatedResponse = PaginatedResponse<PostModel>.fromJson(
        response.data,
        (json) => PostModel.fromJson(json),
        'posts',
      );
      return _populateUsers(paginatedResponse);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }

  @override
  Future<PostModel> getPostById(int id) async {
    final response = await dioClient.dio.get('/posts/$id');
    if (response.statusCode == 200) {
      final post = PostModel.fromJson(response.data);
      final populated = await _populateUsers(
        PaginatedResponse<PostModel>(
            items: [post], total: 1, skip: 0, limit: 1),
      );
      return populated.items.first;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }
}
