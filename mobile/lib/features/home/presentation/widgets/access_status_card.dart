import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';

class AccessStatusCard extends StatelessWidget {
  final DateTime? lastAccess;

  const AccessStatusCard({super.key, this.lastAccess});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accès autorisé',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatLastAccess(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.key,
              color: AppColors.success,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastAccess() {
    if (lastAccess == null) return 'Aucun accès récent';

    final now = DateTime.now();
    final difference = now.difference(lastAccess!);

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      final seconds = difference.inSeconds % 60;
      return 'Dernière connexion $minutes:${seconds.toString().padLeft(2, '0')}';
    } else if (difference.inHours < 24) {
      return 'Dernière connexion il y a ${difference.inHours}h';
    } else {
      return 'Dernière connexion ${DateFormat('dd/MM à HH:mm').format(lastAccess!)}';
    }
  }
} 