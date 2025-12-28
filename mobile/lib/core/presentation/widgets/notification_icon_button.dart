import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/rooting/app_routes.dart';
import 'package:mobile/features/notification/logic/bloc/push_notification_bloc.dart';

class NotificationIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const NotificationIconButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<PushNotificationBloc, PushNotificationState, int>(
      selector: (state) => state.unreadCount,
      builder: (context, unread) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: onPressed ?? () => context.push(AppRoutes.notifications),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Center(
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
