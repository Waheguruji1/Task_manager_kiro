import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/main_navigation_screen.dart';

/// App Routes Configuration
/// 
/// Centralized route management for the Task Manager app
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route names
  static const String welcome = '/welcome';
  static const String main = '/main';
  static const String home = '/home'; // Alias for main

  /// Generate routes for the app
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
      case main:
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  /// Get all available routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      welcome: (context) => const WelcomeScreen(),
      main: (context) => const MainNavigationScreen(),
    };
  }

  /// Handle unknown routes
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const WelcomeScreen(),
      settings: settings,
    );
  }
}