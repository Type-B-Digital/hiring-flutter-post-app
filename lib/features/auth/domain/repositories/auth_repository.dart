import '../../../../core/utils/either.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> getCurrentUser();
  Future<void> logout();
}
