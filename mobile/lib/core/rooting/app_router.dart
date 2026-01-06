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
import 'package:mobile/features/maintenance/logic/bloc/tickets_bloc.dart';
import 'package:mobile/features/maintenance/logic/bloc/tickets_event.dart';
import 'package:mobile/features/maintenance/presentation/screens/tickets_page.dart';
import 'package:mobile/features/maintenance/data/dto/ticket_dto.dart';
import 'package:mobile/features/maintenance/presentation/screens/ticket_detail_page.dart';
import 'package:mobile/features/maintenance/presentation/screens/ticket_form_page.dart';
import 'package:mobile/features/notification/presentation/screens/notifications_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/settings/presentation/screens/settings_page.dart';
import 'package:mobile/features/settings/presentation/screens/help_page.dart';
import 'package:mobile/features/settings/presentation/screens/about_page.dart';
import 'package:mobile/features/access/presentation/screens/scanner_page.dart';
import 'package:mobile/features/access/presentation/screens/my_access_page.dart';
import 'package:mobile/features/splash/logic/bloc/splash_bloc.dart';
import 'package:mobile/features/splash/logic/bloc/splash_state.dart';
import 'package:mobile/features/splash/presentation/screens/splash_page.dart';

class AppRouter {
  final AuthBloc _authBloc;
  final SplashBloc _splashBloc;

  AppRouter(this._authBloc, this._splashBloc);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: RouterRefresh([_authBloc.stream, _splashBloc.stream]),
    redirect: _handleRedirect,
    routes: _buildRoutes(),
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final splashState = _splashBloc.state;
    final authState = _authBloc.state;
    final isAuthPage = state.matchedLocation == AppRoutes.auth;
    final isSplashPage = state.matchedLocation == AppRoutes.splash;

    if (splashState is! SplashCompleted) {
      return isSplashPage ? null : AppRoutes.splash;
    }

    if (authState is AuthInitial) {
      _authBloc.add(AppStarted());
      return null;
    }

    if (authState is AuthLoading) {
      return null;
    }

    if (authState is AuthUnauthenticated) {
      _resetAllBlocs(context);
      return isAuthPage ? null : AppRoutes.auth;
    }

    if (authState is AuthAuthenticated) {
      if (isAuthPage || isSplashPage) {
        _triggerDashboardLoad(context);
        return AppRoutes.home;
      }
      return null;
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
      builder: (_, _) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.maintenanceTickets,
      name: AppRoutes.maintenanceTicketsName,
      redirect: (context, state) {
        final authState = _authBloc.state;
        if (authState is! AuthAuthenticated) {
          return AppRoutes.auth;
        }
        return null;
      },
      builder: (context, state) => const TicketsPage(),
      routes: [
        GoRoute(
          path: 'create',
          name: AppRoutes.maintenanceTicketCreateName,
          redirect: (context, state) {
            final authState = _authBloc.state;
            if (authState is! AuthAuthenticated) {
              return AppRoutes.auth;
            }
            return null;
          },
          builder: (context, state) => const TicketFormPage(),
        ),
        GoRoute(
          path: ':id',
          name: AppRoutes.maintenanceTicketDetailName,
          redirect: (context, state) {
            final authState = _authBloc.state;
            if (authState is! AuthAuthenticated) {
              return AppRoutes.auth;
            }
            return null;
          },
          builder: (context, state) {
            final idParam = state.pathParameters['id'];
            final ticket = state.extra as TicketDTO?;
            final id = int.tryParse(idParam ?? '');
            return TicketDetailPage(ticketId: id, initialTicket: ticket);
          },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: AppRoutes.notificationsName,
      redirect: (context, state) {
        final authState = _authBloc.state;
        if (authState is! AuthAuthenticated) {
          return AppRoutes.auth;
        }
        return null;
      },
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: AppRoutes.myAccess,
      name: AppRoutes.myAccessName,
      redirect: (context, state) {
        final authState = _authBloc.state;
        if (authState is! AuthAuthenticated) {
          return AppRoutes.auth;
        }
        return null;
      },
      builder: (context, state) => const MyAccessPage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: AppRoutes.settingsName,
      redirect: (context, state) {
        final authState = _authBloc.state;
        if (authState is! AuthAuthenticated) {
          return AppRoutes.auth;
        }
        return null;
      },
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'profile',
          name: AppRoutes.settingsProfileName,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: 'notifications',
          name: AppRoutes.settingsNotificationsName,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: 'help',
          name: AppRoutes.settingsHelpName,
          builder: (context, state) => const HelpPage(),
        ),
        GoRoute(
          path: 'about',
          name: AppRoutes.settingsAboutName,
          builder: (context, state) => const AboutPage(),
        ),
      ],
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
                    _triggerDashboardLoad(context);
                  }
                },
                child: const HomePage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.scanner,
              name: AppRoutes.scannerName,
              builder: (context, state) => const ScannerPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings-tab',
              name: 'settingsTab',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ];

  void _triggerDashboardLoad(BuildContext context) {
    final dashboardBloc = context.read<DashboardBloc>();
    final authBloc = context.read<AuthBloc>();
    final state = dashboardBloc.state;

    if (state is DashboardInitial || state is DashboardError) {
      final authState = authBloc.state;
      if (authState is AuthAuthenticated && authState.userInfo != null) {
        dashboardBloc.add(LoadDashboard(userInfo: authState.userInfo!));
      }
    }
  }

  void _resetAllBlocs(BuildContext context) {
    try {
      // Réinitialiser le dashboard
      context.read<DashboardBloc>().add(ResetDashboard());
      print('[AppRouter] ✅ Dashboard reset');
    } catch (e) {
      print('[AppRouter] ⚠️ Erreur reset Dashboard: $e');
    }

    try {
      // Réinitialiser les tickets
      context.read<TicketsBloc>().add(const ResetTickets());
      print('[AppRouter] ✅ Tickets reset');
    } catch (e) {
      print('[AppRouter] ⚠️ Erreur reset Tickets: $e');
    }
  }
}
