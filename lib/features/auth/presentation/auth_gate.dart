import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postsapp/core/injection/injector.dart';
import 'package:postsapp/features/posts/presentation/bloc/post_bloc.dart';
import 'package:postsapp/features/posts/presentation/posts_screen.dart';
import 'bloc/auth_bloc.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadingState || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticatedState) {
          return BlocProvider<PostBloc>(
            create: (_) => sl<PostBloc>(),
            child: const PostsScreen(),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
