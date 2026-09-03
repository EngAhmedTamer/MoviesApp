import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/app/app_router.dart';
import 'package:movies_app/core/di/app_dependencies.dart';
import 'package:movies_app/core/theme/app_theme.dart';
import 'package:movies_app/features/auth/presentation/cubit/auth_cubit.dart';

class MoviesApp extends StatelessWidget {
  MoviesApp({
    required this.dependencies,
    super.key,
  }) : router = AppRouter.create(dependencies);

  final AppDependencies dependencies;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AppDependencies>.value(
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => dependencies.createAuthCubit()..startListening(),
          ),
        ],
        child: MaterialApp.router(
          title: 'Movies App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: router,
        ),
      ),
    );
  }
}
