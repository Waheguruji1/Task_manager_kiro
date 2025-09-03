import 'package:flutter/material.dart';

/// Simplified App Theme for Solo Development
class AppTheme {
  AppTheme._();

  // Core Colors
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceGrey = Color(0xFF1C1C1E);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color disabledText = Color(0xFF636366);
  static const Color greyPrimary = Color(0xFF6B7280);
  static const Color greyLight = Color(0xFF9CA3AF);
  static const Color greyDark = Color(0xFF374151);
  static const Color purplePrimary = Color(0xFF8B5CF6);
  static const Color borderWhite = Colors.transparent;
  static const Color iconPrimary = Color(0xFFFFFFFF);

  // Font Family (using system fonts)
  static const String primaryFontFamily = '';

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: primaryText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: primaryText,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: secondaryText,
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Component Spacing
  static const double screenPadding = 16.0;
  static const double containerMargin = 8.0;
  static const double sectionSpacing = 24.0;

  // Border Radius
  static const double containerBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double inputBorderRadius = 8.0;

  // Elevation
  static const double buttonElevation = 1.0;

  // Simple Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: greyPrimary,
        surface: surfaceGrey,
        onPrimary: primaryText,
        onSurface: primaryText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: primaryText,
        elevation: 0,
        titleTextStyle: headingMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: greyPrimary,
          foregroundColor: primaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
          borderSide: const BorderSide(color: greyPrimary, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected)
              ? greyPrimary
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(primaryText),
      ),
    );
  }

  // Priority Colors
  static const Color priorityHigh = Color(0xFF8B5CF6);
  static const Color priorityMedium = Color(0xFF10B981);

  // Component Decorations (simplified)
  static BoxDecoration get taskContainerDecoration => BoxDecoration(
        color: surfaceGrey,
        borderRadius: BorderRadius.circular(containerBorderRadius),
      );

  static BoxDecoration get routineTaskLabelDecoration => BoxDecoration(
        color: greyPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      );

  // Enhanced UI Properties (for test compatibility)
  static BoxDecoration get enhancedButtonDecoration => BoxDecoration(
        color: greyPrimary,
        borderRadius: BorderRadius.circular(buttonBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static const double visualHierarchySpacing = 12.0;
}
