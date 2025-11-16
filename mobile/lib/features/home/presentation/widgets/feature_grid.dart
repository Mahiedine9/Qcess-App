import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/responsive_utils.dart';
import 'package:mobile/features/home/data/models/feature_data.dart';
import 'package:mobile/features/home/presentation/widgets/feature_button.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final gridColumns = context.gridColumns;
    
    final features = [
      const FeatureData(
        icon: Icons.key,
        label: 'Mes accès',
        color: AppColors.warning,
      ),
      const FeatureData(
        icon: Icons.qr_code_scanner,
        label: 'Ouvrir',
        color: AppColors.primary,
      ),
      const FeatureData(
        icon: Icons.history,
        label: 'Historique',
        color: AppColors.historyColor,
      ),
      const FeatureData(
        icon: Icons.calendar_today,
        label: 'Réservations',
        color: AppColors.reservationsColor,
      ),
      const FeatureData(
        icon: Icons.chat_bubble_outline,
        label: 'Support',
        color: AppColors.supportColor,
      ),
      const FeatureData(
        icon: Icons.build,
        label: 'Tickets',
        color: AppColors.ticketsColor,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns.clamp(2, 3),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return FeatureButton(
          icon: feature.icon,
          label: feature.label,
          color: feature.color,
          onTap: () => _showComingSoon(context, feature.label),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - À venir prochainement'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}