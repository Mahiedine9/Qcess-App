import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/notification/logic/bloc/push_notification_bloc.dart';
import 'package:mobile/features/notification/presentation/widgets/notification_card.dart';
import 'package:mobile/core/rooting/app_routes.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PushNotificationBloc>().add(const NotificationsRequested());
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PushNotificationBloc>().add(const NotificationsLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              const Spacer(),
              BlocBuilder<PushNotificationBloc, PushNotificationState>(
                builder: (context, state) {
                  if (state.unreadCount > 0) {
                    return TextButton.icon(
                      onPressed: () {
                        context.read<PushNotificationBloc>().add(
                          const NotificationsMarkAllAsRead(),
                        );
                      },
                      icon: Icon(
                        Icons.done_all,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                      label: Text(
                        'Tout lire',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<
                          PushNotificationBloc,
                          PushNotificationState
                        >(
                          builder: (context, state) {
                            if (state.unreadCount > 0) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  state.unreadCount > 99
                                      ? '99+'
                                      : '${state.unreadCount}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onError,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Restez informé de vos activités',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<PushNotificationBloc, PushNotificationState>(
      builder: (context, state) {
        switch (state.notificationsStatus) {
          case NotificationsStatus.initial:
          case NotificationsStatus.loading:
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );

          case NotificationsStatus.failure:
            return _buildErrorState(state.errorMessage);

          case NotificationsStatus.loaded:
          case NotificationsStatus.loadingMore:
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            return _buildNotificationsList(state);
        }
      },
    );
  }

  Widget _buildNotificationsList(PushNotificationState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PushNotificationBloc>().add(
          const NotificationsRequested(refresh: true),
        );
      },
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: AppTheme.spacingMedium, bottom: 80),
        itemCount: state.hasReachedMax
            ? state.notifications.length
            : state.notifications.length + 1,
        itemBuilder: (context, index) {
          if (index >= state.notifications.length) {
            return Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          final notification = state.notifications[index];
          return NotificationCard(
            notification: notification,
            onMarkAsRead: () {
              if (!notification.read) {
                context.read<PushNotificationBloc>().add(
                  NotificationMarkAsRead(notification.id),
                );
              }
            },
            onTap: () => _handleNotificationTap(notification),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(notification) {
    final rawType = notification.type ?? '';
    final type = rawType.toString().toUpperCase();

    if (type.contains('TICKET') || type.contains('MAINTENANCE')) {
      context.push(AppRoutes.maintenanceTickets);
      return;
    }

    context.push(AppRoutes.home);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Aucune notification',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Vous n\'avez pas encore reçu de notification.\nElles apparaîtront ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Une erreur est survenue',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              errorMessage ?? 'Impossible de charger les notifications',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PushNotificationBloc>().add(
                  const NotificationsRequested(),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLarge,
                  vertical: AppTheme.spacingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
