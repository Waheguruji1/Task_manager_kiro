import 'package:flutter/material.dart';

/// App Theme Configuration
/// 
/// This file contains the comprehensive theme data for the Task Manager app
/// based on the theme.md specifications. It implements a dark theme with
/// grey accents, white text, and proper color definitions.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color Palette - Strictly Black Background
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceGrey = Color(0xFF1C1C1E);
  
  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color disabledText = Color(0xFF636366);
  
  // Accent Colors - App Theme Style
  static const Color greyPrimary = Color(0xFF6B7280);
  static const Color greyLight = Color(0xFF9CA3AF);
  static const Color greyDark = Color(0xFF374151);
  static const Color purplePrimary = Color(0xFF8B5CF6);
  
  // UI Element Colors - No Borders
  static const Color borderWhite = Colors.transparent;
  static const Color iconPrimary = Color(0xFFFFFFFF);
  static const Color iconBackground = Color(0xFF48484A);

  // Font Family
  static const String primaryFontFamily = 'Sour Gummy';

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: primaryText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: primaryText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: secondaryText,
  );

  // Spacing System
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Component Spacing
  static const double screenPadding = 16.0;
  static const double containerMargin = 8.0;
  static const double elementSpacing = 12.0;
  static const double sectionSpacing = 24.0;

  // Border Radius
  static const double containerBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double inputBorderRadius = 8.0;

  // Elevation and Shadow
  static const double taskContainerElevation = 2.0;
  static const double buttonElevation = 1.0;

  /// Main Dark Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: primaryFontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: greyPrimary,
        primaryContainer: greyDark,
        secondary: greyLight,
        surface: surfaceGrey,
        onPrimary: primaryText,
        onSecondary: primaryText,
        onSurface: primaryText,
        outline: borderWhite,
      ),

      // Scaffold Theme
      scaffoldBackgroundColor: backgroundDark,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingMedium,
        iconTheme: IconThemeData(
          color: iconPrimary,
          size: 24,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelSmall: caption,
        titleMedium: bodyLarge,
        titleSmall: bodyMedium,
      ),

      // Card Theme - iOS Style
      cardTheme: CardThemeData(
        color: surfaceGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(containerBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(vertical: containerMargin),
      ),

      // Elevated Button Theme - iOS Style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: greyPrimary,
          foregroundColor: primaryText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          textStyle: bodyLarge,
        ),
      ),

      // Outlined Button Theme - iOS Style
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          backgroundColor: surfaceGrey,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          textStyle: bodyLarge,
        ),
      ),

      // Input Decoration Theme - iOS Style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: greyPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        hintStyle: const TextStyle(
          color: disabledText,
          fontFamily: primaryFontFamily,
        ),
        labelStyle: const TextStyle(
          color: secondaryText,
          fontFamily: primaryFontFamily,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
      ),

      // Checkbox Theme - iOS Style
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return greyPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(primaryText),
        side: BorderSide(color: greyLight, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryText,
        unselectedLabelColor: secondaryText,
        indicatorColor: borderWhite,
        labelStyle: headingMedium,
        unselectedLabelStyle: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: iconPrimary,
        size: 24,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: greyPrimary,
        foregroundColor: primaryText,
        elevation: buttonElevation,
      ),

      // Dialog Theme - iOS Style
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceGrey,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(containerBorderRadius),
        ),
        titleTextStyle: headingMedium,
        contentTextStyle: bodyMedium,
      ),

      // Divider Theme - iOS Style
      dividerTheme: DividerThemeData(
        color: greyLight.withValues(alpha: 0.3),
        thickness: 0.5,
        space: spacingM,
      ),
    );
  }

  /// Custom component styles that can be used throughout the app
  
  /// Task Container Decoration - iOS Style, No Borders
  static BoxDecoration get taskContainerDecoration => BoxDecoration(
    color: surfaceGrey,
    borderRadius: BorderRadius.circular(containerBorderRadius),
  );

  /// Primary Button Decoration - iOS Style
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: greyPrimary,
    borderRadius: BorderRadius.circular(buttonBorderRadius),
  );

  /// Secondary Button Decoration - iOS Style
  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
    color: surfaceGrey,
    borderRadius: BorderRadius.circular(buttonBorderRadius),
  );

  /// Plus Icon Button Decoration - iOS Style
  static BoxDecoration get plusIconDecoration => BoxDecoration(
    color: greyPrimary,
    shape: BoxShape.circle,
  );

  /// Routine Task Label Decoration - iOS Style
  static BoxDecoration get routineTaskLabelDecoration => BoxDecoration(
    color: greyPrimary.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(6),
  );

  /// Enhanced Button Decoration - iOS Style
  static BoxDecoration get enhancedButtonDecoration => BoxDecoration(
    color: surfaceGrey,
    borderRadius: BorderRadius.circular(buttonBorderRadius),
  );

  /// Priority High Color (Purple)
  static const Color priorityHigh = Color(0xFF8B5CF6);
  
  /// Priority Medium Color (Green)
  static const Color priorityMedium = Color(0xFF10B981);

  /// Enhanced visual hierarchy spacing
  static const double visualHierarchySpacing = 6.0;
}