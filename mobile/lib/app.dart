import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/di/di.dart';
import 'package:mobile/core/rooting/app_router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/services/realtime_session_manager.dart';
import 'package:mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/logic/bloc/auth_state.dart';
import 'package:mobile/features/home/data/repositories/I_dashboard_user_repository.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_bloc.dart';
import 'package:mobile/features/maintenance/data/repositories/i_maintenance_repository.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_bloc.dart';
import 'package:mobile/features/notification/logic/bloc/push_notification_bloc.dart';
import 'package:mobile/features/notification/presentation/notification_initializer.dart';
import 'package:mobile/features/profile/data/repositories/i_profile_repository.dart';
import 'package:mobile/features/profile/logic/bloc/profile_bloc.dart';
import 'package:mobile/features/access/data/repositories/i_access_repository.dart';
import 'package:mobile/features/access/logic/bloc/access_bloc.dart';
import 'package:mobile/features/splash/logic/bloc/splash_bloc.dart';
import 'package:mobile/features/theme/logic/bloc/theme_bloc.dart';
import 'package:mobile/features/theme/logic/bloc/theme_state.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final SplashBloc _splashBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: sl<IAuthRepository>());
    _splashBloc = sl<SplashBloc>();
    _appRouter = AppRouter(_authBloc, _splashBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>.value(value: _splashBloc),
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<DashboardBloc>(
          create: (_) => DashboardBloc(
              dashboardUserRepository: sl<IDashboardUserRepository>()),
        ),
        BlocProvider<TicketsBloc>(
          create: (_) => TicketsBloc(
              maintenanceRepository: sl<IMaintenanceRepository>()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
              profileRepository: sl<IProfileRepository>()),
        ),
        BlocProvider<PushNotificationBloc>(
          create: (_) => sl<PushNotificationBloc>(),
        ),
        BlocProvider<AccessBloc>(
          create: (_) => AccessBloc(
            repository: sl<IAccessRepository>(),
          ),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(),
        ),
      ],
      child: NotificationInitializer(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            try {
              final sessionManager = sl<RealtimeSessionManager>();
              if (authState is AuthAuthenticated) {
                try {
                  final ticketsBloc = context.read<TicketsBloc>();
                  sessionManager.start(ticketsBloc: ticketsBloc);
                } catch (e) {
                  debugPrint('[Session] Failed to start session: $e');
                }
              } else if (authState is AuthUnauthenticated) {
                try {
                  sessionManager.stop();
                } catch (e) {
                  debugPrint('[Session] Failed to stop session: $e');
                }
              }
            } catch (e) {
              debugPrint('[Session] Session manager unavailable: $e');
            }
          },
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              if (themeState.isLoading) {
                return const MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  debugShowCheckedModeBanner: false,
                );
              }

              return MaterialApp.router(
                title: 'Qcess',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                debugShowCheckedModeBanner: false,
                routerConfig: _appRouter.router,
              );
            },
          ),
        ),
      ),
    );
  }
}
