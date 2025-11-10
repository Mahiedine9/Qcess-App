import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 24.0;
    } else if (width < tabletBreakpoint) {
      return 48.0;
    } else if (width < desktopBreakpoint) {
      return 64.0;
    } else {
      return 96.0;
    }
  }

  static double getVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 16.0;
    } else if (width < tabletBreakpoint) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  static double getSpacing(BuildContext context, {double multiplier = 1.0}) {
    final width = MediaQuery.of(context).size.width;
    double baseSpacing;

    if (width < mobileBreakpoint) {
      baseSpacing = 16.0;
    } else if (width < tabletBreakpoint) {
      baseSpacing = 20.0;
    } else {
      baseSpacing = 24.0;
    }

    return baseSpacing * multiplier;
  }

  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    final textScaler = MediaQuery.of(context).textScaler;
    final scaleFactor = textScaler.scale(baseFontSize) / baseFontSize;
    return baseFontSize * scaleFactor.clamp(0.8, 1.2);
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 2; 
    } else if (width < tabletBreakpoint) {
      return 3;
    } else if (width < desktopBreakpoint) {
      return 4;
    } else {
      return 6;
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > desktopBreakpoint) {
      return desktopBreakpoint;
    }
    return width;
  }

  static Widget responsive(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= desktopBreakpoint && desktop != null) {
      return desktop;
    } else if (width >= mobileBreakpoint && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }
}

extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);

  double get horizontalPadding => ResponsiveUtils.getHorizontalPadding(this);
  double get verticalPadding => ResponsiveUtils.getVerticalPadding(this);
  double get spacing => ResponsiveUtils.getSpacing(this);

  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);

  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);

  int get gridColumns => ResponsiveUtils.getGridColumns(this);
}
