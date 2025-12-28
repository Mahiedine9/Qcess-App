import 'package:flutter/material.dart';
import 'package:mobile/core/di/di.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  final bool showEditButton;
  final VoidCallback? onEditPressed;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = 100,
    this.showEditButton = false,
    this.onEditPressed,
  });

  String? _buildFullUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return '$url?ts=${DateTime.now().millisecondsSinceEpoch}';
    }
    final base = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path?ts=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullImageUrl = _buildFullUrl(imageUrl);

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: fullImageUrl != null
              ? ClipOval(
                  child: Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                  ),
                )
              : _buildPlaceholder(context),
        ),
        if (showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditPressed,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
