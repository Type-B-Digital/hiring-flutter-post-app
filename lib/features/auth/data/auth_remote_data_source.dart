import 'package:flutter/widgets.dart';
import 'package:postsapp/core/network/api_client.dart';
import 'package:postsapp/features/auth/domain/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      '/auth/login',
      data: {'username': username, 'password': password, 'expiresInMins': 30},
    );

    debugPrint('Login Called: ${response.data}');

    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Invalid login response');
    }

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.dio.get('/auth/me');

    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Invalid user response');
    }

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
