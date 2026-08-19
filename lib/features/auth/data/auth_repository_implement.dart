import 'package:dio/dio.dart';
import 'package:postsapp/core/error/exception_mapper.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/features/auth/data/auth_local_data_source.dart';
import 'package:postsapp/features/auth/data/auth_remote_data_source.dart';
import 'package:postsapp/features/auth/domain/auth_repository.dart';
import 'package:postsapp/features/auth/domain/user_model.dart';

class AuthRepositoryImplement implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  AuthRepositoryImplement({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Result<UserModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.login(
        username: username,
        password: password,
      );

      await authLocalDataSource.saveToken(user.accessToken);
      await authLocalDataSource.saveUser(user);

      return Result.success(user);
    } on DioException catch (e) {
      return Result.failure(mapDioExceptionToFailure(e));
    } on FormatException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (_) {
      return Result.failure(const UnknownFailure());
    }
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final user = await authRemoteDataSource.getCurrentUser();

      return Result.success(user);
    } on DioException catch (e) {
      return Result.failure(mapDioExceptionToFailure(e));
    } on FormatException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (_) {
      return Result.failure(const UnknownFailure());
    }
  }

  @override
  Future<UserModel?> restoreSession() async {
    final token = await authLocalDataSource.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      return await authRemoteDataSource.getCurrentUser();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await authLocalDataSource.clearAll();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await authLocalDataSource.clearAll();
  }
}
