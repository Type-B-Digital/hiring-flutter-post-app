import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/features/auth/domain/user_model.dart';

abstract class AuthRepository {
  Future<Result<UserModel>> login({
    required String username,
    required String password,
  });

  Future<Result<UserModel>> getCurrentUser();

  Future<UserModel?> restoreSession();

  Future<void> logout();
}
