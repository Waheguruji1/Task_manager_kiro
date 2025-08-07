import 'package:flutter/material.dart';

/// Responsive design utilities for handling different screen sizes and orientations
/// 
/// Provides breakpoints, responsive values, and layout helpers to ensure
/// the app works well across different device sizes and orientations.
class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Minimum and maximum content widths
  static const double minContentWidth = 320;
  static const double maxContentWidth = 800;
  
  /// Get the current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenSize.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }
  
  /// Check if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Check if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  /// Get responsive padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    final isLandscapeMode = isLandscape(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return EdgeInsets.symmetric(
          horizontal: isLandscapeMode ? 24.0 : 16.0,
          vertical: isLandscapeMode ? 12.0 : 16.0,
        );
      case ScreenSize.tablet:
        return EdgeInsets.symmetric(
          horizontal: isLandscapeMode ? 48.0 : 32.0,
          vertical: isLandscapeMode ? 16.0 : 24.0,
        );
      case ScreenSize.desktop:
        return EdgeInsets.symmetric(
          horizontal: isLandscapeMode ? 64.0 : 48.0,
          vertical: isLandscapeMode ? 24.0 : 32.0,
        );
    }
  }
  
  /// Get responsive content width with constraints
  static double getContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getScreenPadding(context);
    final availableWidth = screenWidth - padding.horizontal;
    
    return availableWidth.clamp(minContentWidth, maxContentWidth);
  }
  
  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return 1.0;
      case ScreenSize.tablet:
        return 1.1;
      case ScreenSize.desktop:
        return 1.2;
    }
  }
  
  /// Get responsive spacing value
  static double getSpacing(BuildContext context, double baseSpacing) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return baseSpacing;
      case ScreenSize.tablet:
        return baseSpacing * 1.2;
      case ScreenSize.desktop:
        return baseSpacing * 1.4;
    }
  }
  
  /// Get responsive task container height
  static double getTaskContainerHeight(BuildContext context) {
    final screenSize = getScreenSize(context);
    final isLandscapeMode = isLandscape(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    if (isLandscapeMode) {
      // Reduce height in landscape mode and make it responsive to screen height
      final maxHeight = screenHeight * 0.6;
      switch (screenSize) {
        case ScreenSize.mobile:
          return (300.0).clamp(200.0, maxHeight);
        case ScreenSize.tablet:
          return (350.0).clamp(250.0, maxHeight);
        case ScreenSize.desktop:
          return (400.0).clamp(300.0, maxHeight);
      }
    } else {
      // Standard height in portrait mode with screen height consideration
      final maxHeight = screenHeight * 0.7;
      switch (screenSize) {
        case ScreenSize.mobile:
          return (400.0).clamp(300.0, maxHeight);
        case ScreenSize.tablet:
          return (500.0).clamp(400.0, maxHeight);
        case ScreenSize.desktop:
          return (600.0).clamp(500.0, maxHeight);
      }
    }
  }
  
  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return screenWidth * 0.9; // 90% of screen width
      case ScreenSize.tablet:
        return 500; // Fixed width for tablets
      case ScreenSize.desktop:
        return 600; // Fixed width for desktop
    }
  }
  
  /// Get responsive grid column count
  static int getGridColumnCount(BuildContext context) {
    final screenSize = getScreenSize(context);
    final isLandscapeMode = isLandscape(context);
    
    if (isLandscapeMode) {
      switch (screenSize) {
        case ScreenSize.mobile:
          return 2;
        case ScreenSize.tablet:
          return 3;
        case ScreenSize.desktop:
          return 4;
      }
    } else {
      switch (screenSize) {
        case ScreenSize.mobile:
          return 1;
        case ScreenSize.tablet:
          return 2;
        case ScreenSize.desktop:
          return 3;
      }
    }
  }
  
  /// Check if the screen is small (mobile in portrait)
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile && isPortrait(context);
  }
  
  /// Check if the screen is large (tablet or desktop)
  static bool isLargeScreen(BuildContext context) {
    final screenSize = getScreenSize(context);
    return screenSize == ScreenSize.tablet || screenSize == ScreenSize.desktop;
  }
  
  /// Get safe area padding with responsive adjustments
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safePadding = mediaQuery.padding;
    final isLandscapeMode = isLandscape(context);
    
    // Adjust safe area padding for landscape mode
    if (isLandscapeMode) {
      return EdgeInsets.only(
        top: safePadding.top,
        bottom: safePadding.bottom,
        left: safePadding.left + 16,
        right: safePadding.right + 16,
      );
    }
    
    return safePadding;
  }
  
  /// Get responsive text truncation length based on screen size
  static int getTextTruncationLength(BuildContext context, {int baseLength = 50}) {
    final screenSize = getScreenSize(context);
    final isLandscapeMode = isLandscape(context);
    
    double multiplier = 1.0;
    
    switch (screenSize) {
      case ScreenSize.mobile:
        multiplier = isLandscapeMode ? 1.3 : 1.0;
        break;
      case ScreenSize.tablet:
        multiplier = isLandscapeMode ? 1.8 : 1.5;
        break;
      case ScreenSize.desktop:
        multiplier = isLandscapeMode ? 2.2 : 2.0;
        break;
    }
    
    return (baseLength * multiplier).round();
  }
  
  /// Get responsive button padding
  static EdgeInsets getButtonPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ScreenSize.tablet:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }
  
  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 20}) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return baseSize;
      case ScreenSize.tablet:
        return baseSize * 1.1;
      case ScreenSize.desktop:
        return baseSize * 1.2;
    }
  }
}

/// Screen size categories for responsive design
enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

/// Responsive widget builder that provides screen size context
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize, bool isLandscape) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    
    return builder(context, screenSize, isLandscape);
  }
}

/// Responsive layout widget that adapts to screen size and orientation
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? mobileLandscape;
  final Widget? tabletLandscape;
  final Widget? desktopLandscape;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileLandscape,
    this.tabletLandscape,
    this.desktopLandscape,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    
    if (isLandscape) {
      switch (screenSize) {
        case ScreenSize.mobile:
          return mobileLandscape ?? mobile;
        case ScreenSize.tablet:
          return tabletLandscape ?? tablet ?? mobile;
        case ScreenSize.desktop:
          return desktopLandscape ?? desktop ?? tablet ?? mobile;
      }
    } else {
      switch (screenSize) {
        case ScreenSize.mobile:
          return mobile;
        case ScreenSize.tablet:
          return tablet ?? mobile;
        case ScreenSize.desktop:
          return desktop ?? tablet ?? mobile;
      }
    }
  }
}