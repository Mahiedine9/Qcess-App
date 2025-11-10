import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/rooting/app_router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/home/data/repositories/I_dashboard_user_repository.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_bloc.dart';
import 'package:mobile/features/splash/logic/bloc/splash_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>(
          create: (_) => sl<SplashBloc>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: sl<IAuthRepository>()),
        ),
        BlocProvider<DashboardBloc>(
          create: (_) => DashboardBloc(
              dashboardUserRepository: sl<IDashboardUserRepository>()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final splashBloc = context.read<SplashBloc>();
          final appRouter = AppRouter(authBloc, splashBloc);

          return MaterialApp.router(
            title: 'Qcess',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}