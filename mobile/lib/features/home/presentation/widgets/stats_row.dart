import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/responsive_utils.dart';
import 'package:mobile/features/home/data/models/user_dashboard.dart';

class StatsRow extends StatelessWidget {
  final UserDashboard dashboard;

  const StatsRow({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: dashboard.totalAccess.toString(),
            label: 'accès ce mois',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _StatCard(
            value: dashboard.totalZones.toString(),
            label: 'zones',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final isMobile = context.isMobile;

    final cardPadding = isMobile ? spacing * 1.25 : spacing * 1.5;
    final valueFontSize = ResponsiveUtils.getScaledFontSize(
      context,
      isMobile ? 28 : 32,
    );

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.displayLarge?.copyWith(
              color: color,
              fontSize: valueFontSize,
            ),
          ),
          SizedBox(height: spacing * 0.25),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}