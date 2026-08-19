import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postsapp/core/constants/app_theme.dart';
import 'package:postsapp/core/injection/injector.dart';
import 'package:postsapp/features/auth/presentation/auth_gate.dart';
import 'package:postsapp/features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(SessionCheckRequestedEvent()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Posts App',
        theme: AppTheme.light,
        home: AuthGate(),
      ),
    );
  }
}
