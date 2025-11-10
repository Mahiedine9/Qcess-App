import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/home/data/models/user_dashboard.dart';

class UserProfileHeader extends StatelessWidget {
  final UserDashboard dashboard;

  const UserProfileHeader({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: dashboard.profilePictureUrl != null
                  ? NetworkImage(dashboard.profilePictureUrl!)
                  : null,
              child: dashboard.profilePictureUrl == null
                  ? Text(
                      _getInitials(dashboard.username),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                        fontSize: 32,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          dashboard.username,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Développeur Senior',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(width: 4),
            const Text('⭐', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'ID:EMP-2024-084',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.7),
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