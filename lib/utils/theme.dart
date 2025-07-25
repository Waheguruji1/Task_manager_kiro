import 'package:flutter/material.dart';

/// App Theme Configuration
/// 
/// This file contains the comprehensive theme data for the Task Manager app
/// based on the theme.md specifications. It implements a dark theme with
/// purple accents, white text, and proper color definitions.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color Palette
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFE0E0E0);
  static const Color disabledText = Color(0xFF9E9E9E);
  
  // Accent Colors
  static const Color purplePrimary = Color(0xFF8E44AD);
  static const Color purpleLight = Color(0xFFA569BD);
  static const Color purpleDark = Color(0xFF7D3C98);
  
  // UI Element Colors
  static const Color borderColor = Color(0x33FFFFFF); // 20% opacity white
  static const Color iconPrimary = Color(0xFFFFFFFF);
  static const Color iconAccent = Color(0xFF8E44AD);

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
        primary: purplePrimary,
        primaryContainer: purpleDark,
        secondary: purpleLight,
        surface: surfaceDark,
        onPrimary: primaryText,
        onSecondary: primaryText,
        onSurface: primaryText,
        outline: borderColor,
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

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: taskContainerElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(containerBorderRadius),
          side: const BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: containerMargin),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: purplePrimary,
          foregroundColor: primaryText,
          elevation: buttonElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          textStyle: bodyLarge,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: purplePrimary,
          side: const BorderSide(color: purplePrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          textStyle: bodyLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: borderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: purplePrimary, width: 2),
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
          vertical: spacingS,
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return purplePrimary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(primaryText),
        side: const BorderSide(color: borderColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: purplePrimary,
        unselectedLabelColor: secondaryText,
        indicatorColor: purplePrimary,
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
        backgroundColor: purplePrimary,
        foregroundColor: primaryText,
        elevation: buttonElevation,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(containerBorderRadius),
          side: const BorderSide(color: borderColor),
        ),
        titleTextStyle: headingMedium,
        contentTextStyle: bodyMedium,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: spacingM,
      ),
    );
  }

  /// Custom component styles that can be used throughout the app
  
  /// Task Container Decoration
  static BoxDecoration get taskContainerDecoration => BoxDecoration(
    color: surfaceDark,
    borderRadius: BorderRadius.circular(containerBorderRadius),
    border: Border.all(color: borderColor, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  /// Primary Button Decoration
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: purplePrimary,
    borderRadius: BorderRadius.circular(buttonBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  );

  /// Secondary Button Decoration
  static BoxDecoration get secondaryButtonDecoration => BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(buttonBorderRadius),
    border: Border.all(color: purplePrimary, width: 1),
  );
}