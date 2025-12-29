import 'package:flutter/material.dart';
import 'package:mobile/core/utils/responsive_utils.dart';
import 'package:mobile/core/app_config.dart';
import 'package:mobile/features/home/data/models/user_dashboard.dart';

class UserProfileHeader extends StatelessWidget {
  final UserDashboard dashboard;

  const UserProfileHeader({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final isMobile = context.isMobile;
    
    final avatarRadius = isMobile ? 48.0 : 56.0;
    final initialsFontSize = ResponsiveUtils.getScaledFontSize(
      context,
      isMobile ? 28 : 32,
    );

    final String? avatarUrl = AppConfig.getFullImageUrl(dashboard.profilePictureUrl);
    return Column(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.white,
          backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
              ? NetworkImage(avatarUrl)
              : null,
          child: (avatarUrl == null || avatarUrl.isEmpty)
              ? Text(
                  _getInitials(dashboard.username),
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: initialsFontSize,
                  ),
                )
              : null,
        ),

        SizedBox(height: spacing * 1.5),

        Text(
          dashboard.username,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 22 : 26,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: spacing * 0.5),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dashboard.customRoleName != null &&
                        dashboard.customRoleName!.isNotEmpty
                    ? dashboard.customRoleName!
                    : 'Utilisateur',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 15,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '⭐',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),

        SizedBox(height: spacing * 0.75),
      ],
    );
  }
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}