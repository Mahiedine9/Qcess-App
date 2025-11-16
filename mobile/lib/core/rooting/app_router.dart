import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/presentation/widgets/scaffold_with_nav_bar.dart';
import 'package:mobile/core/rooting/app_routes.dart';
import 'package:mobile/core/rooting/router_refresh.dart';
import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/logic/bloc/auth_event.dart';
import 'package:mobile/features/auth/logic/bloc/auth_state.dart';
import 'package:mobile/features/auth/presentation/screens/auth_page.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_bloc.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_event.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_state.dart';
import 'package:mobile/features/home/presentation/screens/home_page.dart';
import 'package:mobile/features/splash/logic/bloc/splash_bloc.dart';
import 'package:mobile/features/splash/logic/bloc/splash_state.dart';
import 'package:mobile/features/splash/presentation/screens/splash_page.dart';

class AppRouter {
  final AuthBloc _authBloc;
  final SplashBloc _splashBloc;

  AppRouter(this._authBloc, this._splashBloc);


  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: RouterRefresh([
      _authBloc.stream,
      _splashBloc.stream,
    ]),
    redirect: _handleRedirect,
    routes: _buildRoutes(),
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final splashState = _splashBloc.state;
    final authState = _authBloc.state;
    final isAuthPage = state.matchedLocation == AppRoutes.auth;
    final isSplashPage = state.matchedLocation == AppRoutes.splash;

    if (isSplashPage && splashState is! SplashCompleted) {
      return null;
    }

    if (splashState is SplashCompleted && isSplashPage) {
      context.read<AuthBloc>().add(AppStarted());
      if (authState is AuthAuthenticated) {
        _triggerDashboardLoad(context);
        return AppRoutes.home;
      } else {
        return AppRoutes.auth;
      }
    }

    if (authState is! AuthAuthenticated && !isAuthPage && !isSplashPage) {
      return AppRoutes.auth;
    }

    if (authState is AuthAuthenticated && isAuthPage) {
      _triggerDashboardLoad(context);
      return AppRoutes.home;
    }

    return null;
  }


  List<RouteBase> _buildRoutes() => [
        GoRoute(
          path: AppRoutes.auth,
          name: AppRoutes.authName,
          builder: (_, __) => const AuthPage(),
        ),
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          builder: (_, _) => const SplashPage()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  name: AppRoutes.homeName,
                  builder: (context, state) => BlocListener<AuthBloc, AuthState>(
                    listenWhen: (prev, curr) => curr is AuthAuthenticated,
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        _triggerDashboardLoad(context);
                      }
                    },
                    child: const HomePage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ];

  void _triggerDashboardLoad(BuildContext context) {
    final dashboardBloc = context.read<DashboardBloc>();
    final state = dashboardBloc.state;

    if (state is DashboardInitial || state is DashboardError) {
      dashboardBloc.add(LoadDashboard());
    }
  }
}