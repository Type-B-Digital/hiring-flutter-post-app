import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:postsapp/core/constants/app_config.dart';
import 'package:postsapp/core/network/api_client.dart';
import 'package:postsapp/features/auth/data/auth_local_data_source.dart';
import 'package:postsapp/features/auth/data/auth_remote_data_source.dart';
import 'package:postsapp/features/auth/data/auth_repository_implement.dart';
import 'package:postsapp/features/auth/domain/auth_repository.dart';
import 'package:postsapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:postsapp/features/posts/data/post_remote_data_source.dart';
import 'package:postsapp/features/posts/data/post_repository_implement.dart';
import 'package:postsapp/features/posts/domain/post_repository.dart';
import 'package:postsapp/features/posts/presentation/bloc/post_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: dio,
      tokenProvider: () => sl<AuthLocalDataSource>().getToken(),
    ),
  );

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplement(
      authRemoteDataSource: sl<AuthRemoteDataSource>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));

  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImplement(sl<PostsRemoteDataSource>()),
  );
  sl.registerFactory<PostBloc>(() => PostBloc(sl<PostsRepository>()));
}
