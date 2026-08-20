import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/posts/data/datasources/posts_remote_data_source.dart';
import 'features/posts/data/repositories/posts_repository_impl.dart';
import 'features/posts/domain/repositories/posts_repository.dart';
import 'features/posts/presentation/bloc/posts_bloc.dart';
import 'features/posts/presentation/pages/dashboard_screen.dart';
import 'core/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const secureStorage = FlutterSecureStorage();
  final dioClient = DioClient(secureStorage);

  final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    secureStorage: secureStorage,
  );

  final postsRemoteDataSource = PostsRemoteDataSourceImpl(dioClient);
  final postsRepository =
      PostsRepositoryImpl(remoteDataSource: postsRemoteDataSource);

  runApp(MyApp(
    authRepository: authRepository,
    postsRepository: postsRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final PostsRepositoryImpl postsRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.postsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PostsRepository>.value(
      value: postsRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: authRepository)
              ..add(AuthCheckRequested()),
          ),
          BlocProvider<PostsBloc>(
            create: (_) => PostsBloc(postsRepository: postsRepository),
          ),
        ],
        child: MaterialApp(
          title: 'NewsBay',
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthInitial) {
                return const SplashScreen();
              }
              if (state is AuthAuthenticated) {
                return const DashboardScreen();
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
