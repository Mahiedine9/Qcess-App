import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/responsive_utils.dart';

class SplashAnimatedLogo extends StatefulWidget {
  const SplashAnimatedLogo({super.key});

  @override
  State<SplashAnimatedLogo> createState() => _SplashAnimatedLogoState();
}

class _SplashAnimatedLogoState extends State<SplashAnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isMobile = context.isMobile;

    final logoPadding = isMobile ? spacing * 1.5 : spacing * 2;
    final logoSize = isMobile ? 64.0 : 80.0;
    final titleFontSize = ResponsiveUtils.getScaledFontSize(context, isMobile ? 28 : 36);
    final subtitleFontSize = ResponsiveUtils.getScaledFontSize(context, isMobile ? 14 : 16);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(logoPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.key,
                size: logoSize,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: spacing * 1.5),
            Text(
              'Qcess',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: spacing * 0.5),
            Text(
              'Votre accès simplifié',
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}