import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

enum SnackBarType {
  success,
  error,
  info,
  warning,
}

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(config.icon, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: Icons.check_circle_outline,
          backgroundColor: AppColors.success,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          icon: Icons.error_outline,
          backgroundColor: AppColors.error,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          icon: Icons.info_outline,
          backgroundColor: AppColors.primary,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: Icons.warning_amber_outlined,
          backgroundColor: AppColors.warning,
        );
    }
  }
}

class _SnackBarConfig {
  final IconData icon;
  final Color backgroundColor;

  _SnackBarConfig({
    required this.icon,
    required this.backgroundColor,
  });
}