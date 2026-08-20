import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_app/core/error/failures.dart';
import 'package:posts_app/core/utils/either.dart';
import 'package:posts_app/core/widgets/splash_screen.dart';
import 'package:posts_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posts_app/features/auth/domain/entities/user.dart';
import 'package:posts_app/features/posts/data/repositories/posts_repository_impl.dart';

import 'package:posts_app/main.dart';

class MockAuthRepository extends Mock implements AuthRepositoryImpl {}

class MockPostsRepository extends Mock implements PostsRepositoryImpl {}

void main() {
  testWidgets('App should render SplashScreen initially',
      (WidgetTester tester) async {
    final mockAuthRepository = MockAuthRepository();
    final mockPostsRepository = MockPostsRepository();

    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) => Completer<Either<Failure, User>>().future);

    await tester.pumpWidget(MyApp(
      authRepository: mockAuthRepository,
      postsRepository: mockPostsRepository,
    ));

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
