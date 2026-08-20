import 'package:go_router/go_router.dart';
import 'package:post_app/presentation/login_screen.dart';
import 'package:post_app/presentation/post_details_screen.dart';
import 'package:post_app/presentation/post_list_screen.dart';
import 'package:post_app/presentation/profile_screen.dart';
import 'package:post_app/provider/auth_provider.dart';

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: authProvider.isLoggedIn ? '/posts' : '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final atLogin = state.matchedLocation == '/login';
      if (!authProvider.isLoggedIn && !atLogin) return '/login';
      if (authProvider.isLoggedIn && atLogin) return '/posts';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/posts', builder: (context, state) => const PostListScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(
        path: '/posts/:id',
        builder: (context, state) =>
            PostDetailsScreen(id: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
}
