import 'package:flutter/material.dart';

/// Utility class for displaying notification debugging information via snackbars
/// 
/// Provides different snackbar styles for various types of notification messages:
/// - Success: Green snackbar for successful operations
/// - Error: Red snackbar for errors with actionable guidance
/// - Warning: Orange snackbar for warnings and potential issues
/// - Info: Blue snackbar for informational messages
class NotificationDebugSnackbar {
  /// Show a success snackbar for successful notification operations
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
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
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an error snackbar with actionable guidance for notification issues
  static void showError(BuildContext context, String message, {String? actionText, VoidCallback? onAction}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error,
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
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: actionText != null && onAction != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Show a warning snackbar for potential notification issues
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning,
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
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an info snackbar for informational notification messages
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info,
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
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show a permission error with guidance to open settings
  static void showPermissionError(BuildContext context, String message, VoidCallback onOpenSettings) {
    showError(
      context,
      message,
      actionText: 'Settings',
      onAction: onOpenSettings,
    );
  }

  /// Show timezone initialization error with recovery option
  static void showTimezoneError(BuildContext context, String message, VoidCallback onRetry) {
    showError(
      context,
      message,
      actionText: 'Retry',
      onAction: onRetry,
    );
  }

  /// Show channel creation error with recovery option
  static void showChannelError(BuildContext context, String message, VoidCallback onRetry) {
    showError(
      context,
      message,
      actionText: 'Retry',
      onAction: onRetry,
    );
  }

  /// Show scheduling success with task details
  static void showSchedulingSuccess(BuildContext context, String taskTitle, DateTime scheduledTime) {
    showSuccess(
      context,
      'Reminder set for "$taskTitle" at ${_formatTime(scheduledTime)}',
    );
  }

  /// Show scheduling error with clear guidance
  static void showSchedulingError(BuildContext context, String taskTitle, String reason) {
    showError(
      context,
      'Failed to set reminder for "$taskTitle": $reason',
    );
  }

  /// Show initialization success
  static void showInitializationSuccess(BuildContext context) {
    showSuccess(
      context,
      'Notification system initialized successfully',
    );
  }

  /// Show initialization error with retry option
  static void showInitializationError(BuildContext context, String error, VoidCallback onRetry) {
    showError(
      context,
      'Notification system failed to initialize: $error',
      actionText: 'Retry',
      onAction: onRetry,
    );
  }

  /// Show service recovery success
  static void showRecoverySuccess(BuildContext context) {
    showSuccess(
      context,
      'Notification service recovered successfully',
    );
  }

  /// Show service recovery failure
  static void showRecoveryFailure(BuildContext context, String reason) {
    showError(
      context,
      'Service recovery failed: $reason',
    );
  }

  /// Show test notification success
  static void showTestSuccess(BuildContext context) {
    showSuccess(
      context,
      'Test notification sent successfully',
    );
  }

  /// Show test notification failure
  static void showTestFailure(BuildContext context, String reason) {
    showError(
      context,
      'Test notification failed: $reason',
    );
  }

  /// Format time for display in snackbars
  static String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}