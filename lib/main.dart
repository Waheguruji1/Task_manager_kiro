import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'utils/error_handler.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/preferences_service.dart';
import 'services/database_service.dart';
import 'widgets/app_icon.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandler.logError(
      details.exception,
      stackTrace: details.stack,
      context: 'Flutter Framework Error',
      type: ErrorType.unknown,
    );
  };
  
  // Set system UI overlay style for status bar and navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App Configuration
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      
      // Navigation Configuration
      home: const AppInitializer(),
      routes: {
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
      },
      
      // Default route for undefined routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        );
      },
      
      // App-wide configuration
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling doesn't break the UI
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

/// App Initializer Widget
/// 
/// Handles initial app setup and navigation logic based on user data.
/// Checks for existing username and navigates to appropriate screen.
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> with WidgetsBindingObserver {
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App is resumed, could check for routine task resets here
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        // App is paused, could save any pending data
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        // App is being terminated, cleanup resources
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App is inactive or hidden, no specific action needed
        break;
    }
  }

  /// Handle app resumed state
  void _handleAppResumed() {
    // Could implement routine task reset logic here
    // For now, just log the event
    debugPrint('App resumed');
  }

  /// Handle app paused state
  void _handleAppPaused() {
    // Could save any pending data here
    debugPrint('App paused');
  }

  /// Handle app detached state
  void _handleAppDetached() async {
    // Cleanup database connection when app is terminated
    try {
      final databaseService = await DatabaseService.getInstance();
      await databaseService.close();
      ErrorHandler.logError('Database connection closed successfully', context: 'App lifecycle', type: ErrorType.unknown);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Close database on app detached', type: ErrorType.database);
    }
  }

  /// Initialize app and determine initial navigation
  Future<void> _initializeApp() async {
    try {
      // Initialize database service first
      final databaseService = await DatabaseService.getInstance();
      await databaseService.initialize();
      
      // Initialize preferences service
      final preferencesService = await PreferencesService.getInstance();
      
      // Check if user has already entered their name
      final hasUserName = await preferencesService.hasUserName();
      
      // Add a small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        if (hasUserName) {
          // User exists, navigate to home screen
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          // New user, navigate to welcome screen
          Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
        }
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'App initialization', type: ErrorType.database);
      
      // On error, still try to navigate to welcome screen
      // This ensures the app doesn't get stuck on the loading screen
      if (mounted) {
        try {
          Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
        } catch (navigationError) {
          ErrorHandler.logError(navigationError, context: 'Navigation fallback', type: ErrorType.unknown);
          // If navigation also fails, show error screen
          _showErrorScreen();
        }
      }
    }
  }

  /// Show error screen when initialization completely fails
  void _showErrorScreen() {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = AppStrings.errorDatabaseConnection;
      });
    }
  }

  /// Retry app initialization
  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo with animation
            AnimatedAppIcon(
              size: 80,
              isAnimating: !_hasError,
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // App name
            Text(
              AppConstants.appName,
              style: AppTheme.headingLarge,
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Show error or loading state
            if (_hasError) ...[
              // Error state
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                _errorMessage ?? AppStrings.errorGeneral,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton.icon(
                onPressed: _retryInitialization,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purplePrimary,
                  foregroundColor: AppTheme.primaryText,
                ),
              ),
            ] else ...[
              // Loading state
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purplePrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


