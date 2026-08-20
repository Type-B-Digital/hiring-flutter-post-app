import 'package:flutter_test/flutter_test.dart';
import 'package:posts_app/features/auth/data/models/user_model.dart';

void main() {
  const tUserModel = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    image: 'https://dummyjson.com/icon/emilys/128',
    token: 'accessToken123',
  );

  final tJson = {
    'id': 1,
    'username': 'emilys',
    'email': 'emily.johnson@x.dummyjson.com',
    'firstName': 'Emily',
    'lastName': 'Johnson',
    'image': 'https://dummyjson.com/icon/emilys/128',
    'accessToken': 'accessToken123',
  };

  group('UserModel', () {
    test('fromJson_withCompleteJson_returnsUserModel', () {
      final result = UserModel.fromJson(tJson);
      expect(result, tUserModel);
    });

    test('fromJson_withMissingImage_returnsUserModelWithNullImage', () {
      final json = Map<String, dynamic>.from(tJson)..remove('image');
      final result = UserModel.fromJson(json);
      expect(result.image, isNull);
    });

    test('toJson_returnsExpectedMap', () {
      final result = tUserModel.toJson();
      expect(result, tJson);
    });
  });
}
