import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Comprehensive permission service for handling all notification-related permissions
/// 
/// This service handles:
/// - Basic notification permissions (Android 13+, iOS)
/// - Exact alarm permissions (Android 12+)
/// - User-friendly permission request flows
/// - Permission status checking and recovery
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  FlutterLocalNotificationsPlugin? _notificationsPlugin;

  /// Initialize the permission service with the notifications plugin
  void initialize(FlutterLocalNotificationsPlugin plugin) {
    _notificationsPlugin = plugin;
  }

  /// Check if all required permissions are granted
  Future<PermissionStatus> checkAllPermissions() async {
    if (_notificationsPlugin == null) {
      return PermissionStatus.notInitialized;
    }

    try {
      // Check basic notification permissions
      final basicPermissions = await _checkBasicNotificationPermissions();
      
      // Check exact alarm permissions (Android only)
      final exactAlarmPermissions = await _checkExactAlarmPermissions();

      // Determine overall status
      if (!basicPermissions) {
        return PermissionStatus.basicNotificationsDenied;
      }
      
      if (Platform.isAndroid && !exactAlarmPermissions) {
        return PermissionStatus.exactAlarmsDenied;
      }

      return PermissionStatus.allGranted;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return PermissionStatus.error;
    }
  }

  /// Request all required permissions with user-friendly flow
  Future<PermissionRequestResult> requestAllPermissions({
    required BuildContext context,
    bool showDialogs = true,
  }) async {
    if (_notificationsPlugin == null) {
      return PermissionRequestResult(
        success: false,
        message: 'Permission service not initialized',
        needsManualAction: false,
      );
    }

    try {
      // Step 1: Request basic notification permissions
      final basicResult = await _requestBasicNotificationPermissions(
        context: context,
        showDialogs: showDialogs,
      );

      if (!basicResult.success) {
        return basicResult;
      }

      // Step 2: Request exact alarm permissions (Android only)
      if (Platform.isAndroid && context.mounted) {
        final exactAlarmResult = await _requestExactAlarmPermissions(
          context: context,
          showDialogs: showDialogs,
        );

        if (!exactAlarmResult.success) {
          // Even if exact alarms fail, basic notifications might work
          return PermissionRequestResult(
            success: true,
            message: 'Basic notifications enabled. For precise timing, please enable exact alarms in settings.',
            needsManualAction: true,
            partialSuccess: true,
          );
        }
      }

      return PermissionRequestResult(
        success: true,
        message: 'All notification permissions granted!',
        needsManualAction: false,
      );
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return PermissionRequestResult(
        success: false,
        message: 'Failed to request permissions: ${e.toString()}',
        needsManualAction: false,
      );
    }
  }

  /// Check basic notification permissions
  Future<bool> _checkBasicNotificationPermissions() async {
    if (_notificationsPlugin == null) return false;

    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin!
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidImplementation == null) return false;
        
        return await androidImplementation.areNotificationsEnabled() ?? false;
      } else if (Platform.isIOS) {
        final iosImplementation = _notificationsPlugin!
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        
        if (iosImplementation == null) return false;
        
        final result = await iosImplementation.checkPermissions();
        return result?.isEnabled ?? false;
      }
    } catch (e) {
      debugPrint('Error checking basic notification permissions: $e');
    }

    return false;
  }

  /// Check exact alarm permissions (Android only)
  Future<bool> _checkExactAlarmPermissions() async {
    if (!Platform.isAndroid || _notificationsPlugin == null) return true;

    try {
      final androidImplementation = _notificationsPlugin!
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation == null) return false;
      
      return await androidImplementation.canScheduleExactNotifications() ?? false;
    } catch (e) {
      debugPrint('Error checking exact alarm permissions: $e');
      return false;
    }
  }

  /// Request basic notification permissions with user guidance
  Future<PermissionRequestResult> _requestBasicNotificationPermissions({
    required BuildContext context,
    bool showDialogs = true,
  }) async {
    try {
      // Check if already granted
      if (await _checkBasicNotificationPermissions()) {
        return PermissionRequestResult(
          success: true,
          message: 'Notification permissions already granted',
          needsManualAction: false,
        );
      }

      // Show explanation dialog if requested
      if (showDialogs && context.mounted) {
        final shouldProceed = await _showPermissionExplanationDialog(
          context,
          'Notification Permission',
          'This app needs notification permission to remind you about your tasks. '
          'You can disable specific notifications in settings later.',
        );

        if (!shouldProceed || !context.mounted) {
          return PermissionRequestResult(
            success: false,
            message: 'User cancelled permission request',
            needsManualAction: false,
          );
        }
      }

      // Request permissions
      bool granted = false;
      
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin!
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidImplementation != null) {
          granted = await androidImplementation.requestNotificationsPermission() ?? false;
        }
      } else if (Platform.isIOS) {
        final iosImplementation = _notificationsPlugin!
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        
        if (iosImplementation != null) {
          granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ?? false;
        }
      }

      if (granted) {
        return PermissionRequestResult(
          success: true,
          message: 'Notification permissions granted!',
          needsManualAction: false,
        );
      } else {
        return PermissionRequestResult(
          success: false,
          message: 'Notification permission denied. Please enable in device settings.',
          needsManualAction: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting basic notification permissions: $e');
      return PermissionRequestResult(
        success: false,
        message: 'Failed to request notification permissions: ${e.toString()}',
        needsManualAction: false,
      );
    }
  }

  /// Request exact alarm permissions (Android only)
  Future<PermissionRequestResult> _requestExactAlarmPermissions({
    required BuildContext context,
    bool showDialogs = true,
  }) async {
    if (!Platform.isAndroid) {
      return PermissionRequestResult(
        success: true,
        message: 'Exact alarms not needed on this platform',
        needsManualAction: false,
      );
    }

    try {
      // Check if already granted
      if (await _checkExactAlarmPermissions()) {
        return PermissionRequestResult(
          success: true,
          message: 'Exact alarm permissions already granted',
          needsManualAction: false,
        );
      }

      // Show explanation dialog if requested
      if (showDialogs && context.mounted) {
        final shouldProceed = await _showPermissionExplanationDialog(
          context,
          'Precise Timing Permission',
          'For accurate task reminders, this app needs permission to schedule exact alarms. '
          'This ensures your notifications appear at the exact time you set.\n\n'
          'You will be taken to system settings to enable this permission.',
        );

        if (!shouldProceed) {
          return PermissionRequestResult(
            success: false,
            message: 'User cancelled exact alarm permission request',
            needsManualAction: false,
          );
        }
      }

      // Request exact alarm permission (opens system settings)
      final androidImplementation = _notificationsPlugin!
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation == null) {
        return PermissionRequestResult(
          success: false,
          message: 'Android implementation not available',
          needsManualAction: false,
        );
      }

      // This opens system settings
      await androidImplementation.requestExactAlarmsPermission();

      // Wait a moment for user to return from settings
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if permission was granted
      final granted = await _checkExactAlarmPermissions();

      if (granted) {
        return PermissionRequestResult(
          success: true,
          message: 'Exact alarm permissions granted!',
          needsManualAction: false,
        );
      } else {
        return PermissionRequestResult(
          success: false,
          message: 'Exact alarm permission not granted. Notifications may be less precise.',
          needsManualAction: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting exact alarm permissions: $e');
      return PermissionRequestResult(
        success: false,
        message: 'Failed to request exact alarm permissions: ${e.toString()}',
        needsManualAction: false,
      );
    }
  }

  /// Show permission explanation dialog
  Future<bool> _showPermissionExplanationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    if (!context.mounted) return false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Get user-friendly permission status message
  Future<String> getPermissionStatusMessage() async {
    final status = await checkAllPermissions();
    
    switch (status) {
      case PermissionStatus.allGranted:
        return 'All notification permissions are enabled';
      case PermissionStatus.basicNotificationsDenied:
        return 'Notification permission is required for task reminders';
      case PermissionStatus.exactAlarmsDenied:
        return 'Basic notifications enabled. Enable exact alarms for precise timing';
      case PermissionStatus.notInitialized:
        return 'Permission service not initialized';
      case PermissionStatus.error:
        return 'Error checking permission status';
    }
  }

  /// Show settings dialog to guide user to enable permissions manually
  Future<void> showSettingsDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'To receive task reminders, please enable notifications in your device settings:\n\n'
            '1. Go to Settings\n'
            '2. Find this app\n'
            '3. Enable Notifications\n'
            '4. Enable "Alarms & reminders" (Android 12+)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

/// Permission status enum
enum PermissionStatus {
  allGranted,
  basicNotificationsDenied,
  exactAlarmsDenied,
  notInitialized,
  error,
}

/// Permission request result
class PermissionRequestResult {
  final bool success;
  final String message;
  final bool needsManualAction;
  final bool partialSuccess;

  PermissionRequestResult({
    required this.success,
    required this.message,
    required this.needsManualAction,
    this.partialSuccess = false,
  });
}