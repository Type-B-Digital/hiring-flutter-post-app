import '../../features/auth/domain/entities/user.dart';

class UserDisplayUtils {
  static String initialsFor(User user) {
    if (user.firstName.isNotEmpty && user.lastName.isNotEmpty) {
      return '${user.firstName[0].toUpperCase()}${user.lastName[0].toUpperCase()}';
    }
    if (user.username.isNotEmpty) {
      return user.username
          .substring(0, user.username.length > 1 ? 2 : 1)
          .toUpperCase();
    }
    return 'G';
  }
}
