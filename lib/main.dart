import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:post_app/app_config.dart';
import 'package:post_app/provider/auth_provider.dart';
import 'package:post_app/provider/post_provider.dart';
import 'package:post_app/provider/theme_provider.dart';
import 'package:post_app/repository/auth_repository.dart';
import 'package:post_app/repository/post_repository.dart';
import 'package:post_app/repository/session_storage.dart';
import 'package:post_app/routing/app_router.dart';
import 'package:post_app/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
  final authRepository = AuthRepositoryImpl(dio, SessionStorage());
  final savedUser = await authRepository.restoreSession();

  final authProvider = AuthProvider(authRepository, user: savedUser);
  final postProvider = PostProvider(PostRepositoryImpl(dio));
  final router = buildRouter(authProvider);

  runApp(MyApp(authProvider: authProvider, postProvider: postProvider, router: router));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final PostProvider postProvider;
  final GoRouter router;

  const MyApp({
    super.key,
    required this.authProvider,
    required this.postProvider,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: postProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'NewsBay',
            theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
