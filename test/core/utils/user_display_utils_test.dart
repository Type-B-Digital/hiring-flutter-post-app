import 'package:flutter_test/flutter_test.dart';
import 'package:posts_app/core/utils/user_display_utils.dart';
import 'package:posts_app/features/auth/domain/entities/user.dart';

void main() {
  group('UserDisplayUtils.initialsFor', () {
    test('withFirstAndLastName_returnsBothInitials', () {
      const user = User(
        id: 1,
        username: 'emilys',
        email: 'emily.johnson@x.dummyjson.com',
        firstName: 'Emily',
        lastName: 'Johnson',
        token: 'token',
      );

      expect(UserDisplayUtils.initialsFor(user), 'EJ');
    });

    test('withOnlyUsername_returnsFirstTwoCharsUppercased', () {
      const user = User(
        id: 1,
        username: 'emilys',
        email: 'emily.johnson@x.dummyjson.com',
        firstName: '',
        lastName: '',
        token: 'token',
      );

      expect(UserDisplayUtils.initialsFor(user), 'EM');
    });

    test('withSingleCharacterUsername_returnsThatCharUppercased', () {
      const user = User(
        id: 1,
        username: 'e',
        email: 'e@x.dummyjson.com',
        firstName: '',
        lastName: '',
        token: 'token',
      );

      expect(UserDisplayUtils.initialsFor(user), 'E');
    });

    test('withNoNameOrUsername_returnsGDefault', () {
      const user = User(
        id: 1,
        username: '',
        email: 'guest@x.dummyjson.com',
        firstName: '',
        lastName: '',
        token: 'token',
      );

      expect(UserDisplayUtils.initialsFor(user), 'G');
    });
  });
}
