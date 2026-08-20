import 'package:dio/dio.dart';
import 'package:post_app/models/auth_user.dart';
import 'package:post_app/repository/session_storage.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String username, required String password});
  Future<AuthUser?> restoreSession();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SessionStorage _sessionStorage;

  AuthRepositoryImpl(this._dio, this._sessionStorage);

  @override
  Future<AuthUser> login({required String username, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password, 'expiresInMins': 1},
      );
      final user = AuthUser.fromJson(response.data as Map<String, dynamic>);
      await _sessionStorage.saveSession(user);
      return user;
    } on DioException catch (e) {
      throw Exception(_messageFor(e));
    }
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final saved = await _sessionStorage.readSession();
    if (saved == null) return null;

    try {
      //authenticate the saved token with the server to check if it's still valid
      await _dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer ${saved.accessToken}'}),
      );
      return saved;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        //logged out if token expired — clear the cached session
        await _sessionStorage.clearSession();
        return null;
      }
      // keep the cached session on network errors
      return saved;
    }
  }

  @override
  Future<void> logout() => _sessionStorage.clearSession();

  String _messageFor(DioException e) {
    final status = e.response?.statusCode;
    if (status == 400 || status == 401) {
      return 'Invalid username or password.';
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'No internet connection. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
