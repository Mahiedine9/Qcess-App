import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/core/presentation/widgets/scaffold_with_nav_bar.dart';
import 'package:mobile/core/rooting/app_routes.dart';
import 'package:mobile/core/rooting/router_refresh.dart';

import 'package:mobile/features/auth/logic/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/logic/bloc/auth_state.dart';
import 'package:mobile/features/auth/presentation/screens/auth_page.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_bloc.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_event.dart';
import 'package:mobile/features/home/logic/bloc/dashboard_state.dart';
import 'package:mobile/features/home/presentation/screens/home_page.dart';

class AppRouter {
  final AuthBloc _authBloc;

  AppRouter(this._authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.auth,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: _handleRedirect,
    routes: _buildRoutes(),
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final isAuthPage = state.matchedLocation == AppRoutes.auth;

    if (authState is! AuthAuthenticated && !isAuthPage) {
      return AppRoutes.auth;
    }

    if (authState is AuthAuthenticated && isAuthPage) {
      _triggerDashboardLoad(context, authState.user.id);
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
                        _triggerDashboardLoad(context, state.user.id);
                      }
                    },
                    child: const HomePage(),
                  ),
                ),
              ],
            ),
            // TODO: Ajouter d'autres branches pour les pages profile, scanner, settings
          ],
        ),
      ];

  void _triggerDashboardLoad(BuildContext context, int userId) {
    final dashboardBloc = context.read<DashboardBloc>();
    final state = dashboardBloc.state;

    if (state is DashboardInitial || state is DashboardError) {
      debugPrint('[ROUTER] Triggering LoadDashboard...');
      dashboardBloc.add(LoadDashboard(userId));
    }
  }
}
