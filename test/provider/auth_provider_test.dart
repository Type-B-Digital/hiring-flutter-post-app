import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:post_app/models/auth_user.dart';
import 'package:post_app/provider/auth_provider.dart';
import 'package:post_app/repository/auth_repository.dart';

// fake repo so we don't hit the real API in tests
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late AuthProvider provider;

  const testUser = AuthUser(
    id: 1,
    username: 'emilys',
    email: 'emily@x.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    image: 'https://x.com/emily.png',
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    provider = AuthProvider(mockRepo);
  });

  test('login works when password is correct', () async {
    when(
      () => mockRepo.login(username: 'emilys', password: 'emilyspass'),
    ).thenAnswer((_) async => testUser);

    await provider.login('emilys', 'emilyspass');

    expect(provider.isLoggedIn, true);
    expect(provider.user, testUser);
  });

  test('wrong password shows an error', () async {
    when(
      () => mockRepo.login(username: 'emilys', password: 'wrongpass'),
    ).thenThrow(Exception('Invalid username or password.'));

    await provider.login('emilys', 'wrongpass');

    expect(provider.isLoggedIn, false);
    expect(provider.errorMessage, 'Invalid username or password.');
  });

  test('logout works', () async {
    when(
      () => mockRepo.login(username: 'emilys', password: 'emilyspass'),
    ).thenAnswer((_) async => testUser);
    when(() => mockRepo.logout()).thenAnswer((_) async {});
    await provider.login('emilys', 'emilyspass');

    await provider.logout();

    expect(provider.isLoggedIn, false);
    expect(provider.user, null);
  });
}
