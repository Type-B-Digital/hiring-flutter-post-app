import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await dioClient.dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
        'expiresInMins': 60,
      },
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await dioClient.dio.get('/auth/me');
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }
}
