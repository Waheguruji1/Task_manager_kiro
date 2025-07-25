import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'theme.dart';

/// Error types that can occur in the app
enum ErrorType {
  database,
  preferences,
  validation,
  network,
  unknown,
}

/// Custom exception class for app-specific errors
class AppException implements Exception {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppException: $message (Type: $type)';
  }
}

/// Error handler utility class
class ErrorHandler {
  ErrorHandler._();

  /// Log error with appropriate level
  static void logError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    ErrorType type = ErrorType.unknown,
  }) {
    final errorMessage = _formatErrorMessage(error, context, type);
    
    if (kDebugMode) {
      // In debug mode, print to console
      print('ERROR: $errorMessage');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    } else {
      // In production, you would send to crash reporting service
      // For now, we'll just use debugPrint which is stripped in release
      debugPrint('ERROR: $errorMessage');
    }
  }

  /// Format error message for logging
  static String _formatErrorMessage(
    dynamic error,
    String? context,
    ErrorType type,
  ) {
    final buffer = StringBuffer();
    
    if (context != null) {
      buffer.write('[$context] ');
    }
    
    buffer.write('[${type.name.toUpperCase()}] ');
    
    if (error is AppException) {
      buffer.write(error.message);
      if (error.originalError != null) {
        buffer.write(' (Original: ${error.originalError})');
      }
    } else {
      buffer.write(error.toString());
    }
    
    return buffer.toString();
  }

  /// Handle database errors and return user-friendly message
  static String handleDatabaseError(dynamic error, {String? context}) {
    logError(error, context: context ?? 'Database', type: ErrorType.database);
    
    if (error is AppException) {
      return error.message;
    }
    
    // Map common database errors to user-friendly messages
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('database') && errorString.contains('locked')) {
      return AppStrings.errorDatabaseLocked;
    } else if (errorString.contains('no such table')) {
      return AppStrings.errorDatabaseCorrupted;
    } else if (errorString.contains('constraint')) {
      return AppStrings.errorDatabaseConstraint;
    } else {
      return AppStrings.errorDatabaseConnection;
    }
  }

  /// Handle preferences errors and return user-friendly message
  static String handlePreferencesError(dynamic error, {String? context}) {
    logError(error, context: context ?? 'Preferences', type: ErrorType.preferences);
    
    if (error is AppException) {
      return error.message;
    }
    
    return AppStrings.errorPreferences;
  }

  /// Handle validation errors
  static String handleValidationError(dynamic error, {String? context}) {
    logError(error, context: context ?? 'Validation', type: ErrorType.validation);
    
    if (error is AppException) {
      return error.message;
    }
    
    return AppStrings.errorValidation;
  }

  /// Handle unknown errors
  static String handleUnknownError(dynamic error, {String? context}) {
    logError(error, context: context ?? 'Unknown', type: ErrorType.unknown);
    
    if (error is AppException) {
      return error.message;
    }
    
    return AppStrings.errorGeneral;
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.purplePrimary,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_outlined,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade400,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }
}

/// Error display widget for showing errors in UI
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? iconColor;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? Colors.red.shade400,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              message,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purplePrimary,
                  foregroundColor: AppTheme.primaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading widget with error handling
class LoadingWidget extends StatelessWidget {
  final String message;
  final bool showMessage;

  const LoadingWidget({
    super.key,
    this.message = AppStrings.loadingTasks,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purplePrimary),
          ),
          if (showMessage) ...[
            const SizedBox(height: AppTheme.spacingM),
            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionText = AppStrings.emptyStateAction,
    this.onAction,
    this.icon = Icons.task_alt_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              title,
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purplePrimary,
                  foregroundColor: AppTheme.primaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}