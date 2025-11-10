import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/responsive_utils.dart';
import 'package:mobile/features/home/data/models/user_dashboard.dart';

class UserProfileHeader extends StatelessWidget {
  final UserDashboard dashboard;

  const UserProfileHeader({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final isMobile = context.isMobile;

    final avatarRadius = isMobile ? 40.0 : 50.0;
    final editIconPadding = isMobile ? 4.0 : 6.0;
    final editIconSize = isMobile ? 14.0 : 16.0;
    final initialsFontSize = ResponsiveUtils.getScaledFontSize(
      context,
      isMobile ? 28 : 32,
    );

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.white,
              backgroundImage: dashboard.profilePictureUrl != null
                  ? NetworkImage(dashboard.profilePictureUrl!)
                  : null,
              child: dashboard.profilePictureUrl == null
                  ? Text(
                      _getInitials(dashboard.username),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                        fontSize: initialsFontSize,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(editIconPadding),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: editIconSize,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Text(
          dashboard.username,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing * 0.25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Développeur Senior',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            SizedBox(width: spacing * 0.25),
            const Text('⭐', style: TextStyle(fontSize: 16)),
          ],
        ),
        SizedBox(height: spacing * 0.25),
        Text(
          'ID:EMP-2024-084',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}