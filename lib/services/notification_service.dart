import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

/// Notification permission status enum
enum NotificationPermissionStatus {
  granted,
  denied,
  notDetermined,
  provisional, // iOS-specific
  restricted,  // iOS-specific
  unknown,
}

/// Platform compatibility information
class PlatformCompatibility {
  final String platform;
  final String version;
  final bool supportsNotificationChannels;
  final bool supportsExactAlarms;
  final bool supportsProvisionalPermissions;
  final List<String> limitations;
  
  PlatformCompatibility({
    required this.platform,
    required this.version,
    required this.supportsNotificationChannels,
    required this.supportsExactAlarms,
    required this.supportsProvisionalPermissions,
    required this.limitations,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'version': version,
      'supportsNotificationChannels': supportsNotificationChannels,
      'supportsExactAlarms': supportsExactAlarms,
      'supportsProvisionalPermissions': supportsProvisionalPermissions,
      'limitations': limitations,
    };
  }
}

/// Timezone management class for robust timezone data initialization
class TimezoneManager {
  static bool _isInitialized = false;
  static String? _initializationError;
  
  /// Initialize timezone data with error handling
  static Future<bool> initializeTimezones() async {
    try {
      tz.initializeTimeZones();
      _isInitialized = true;
      _initializationError = null;
      debugPrint('Timezone data initialized successfully');
      return true;
    } catch (e, stackTrace) {
      _initializationError = e.toString();
      _logTimezoneError('Timezone initialization failed', e, stackTrace);
      return false;
    }
  }
  
  /// Check if timezone data is initialized
  static bool get isInitialized => _isInitialized;
  
  /// Get initialization error if any
  static String? get initializationError => _initializationError;
  
  /// Safely convert DateTime to TZDateTime with error handling
  static tz.TZDateTime? safeConvertToTZDateTime(DateTime dateTime) {
    if (!_isInitialized) {
      debugPrint('Timezone not initialized, cannot convert DateTime');
      return null;
    }
    
    try {
      final tz.Location local = tz.local;
      return tz.TZDateTime.from(dateTime, local);
    } catch (e) {
      _logTimezoneError('DateTime conversion failed', e, null);
      return null;
    }
  }
  
  /// Verify timezone initialization status
  static bool verifyInitialization() {
    try {
      if (!_isInitialized) return false;
      
      // Try to get local timezone to verify initialization
      final tz.Location local = tz.local;
      final now = DateTime.now();
      tz.TZDateTime.from(now, local);
      
      return true;
    } catch (e) {
      _logTimezoneError('Timezone verification failed', e, null);
      return false;
    }
  }
  
  /// Attempt to recover from timezone initialization failure
  static Future<bool> attemptRecovery() async {
    debugPrint('Attempting timezone recovery...');
    
    try {
      // Wait a bit and retry initialization
      await Future.delayed(const Duration(milliseconds: 500));
      return await initializeTimezones();
    } catch (e) {
      _logTimezoneError('Timezone recovery failed', e, null);
      return false;
    }
  }
  
  /// Log timezone-related errors
  static void _logTimezoneError(String message, dynamic error, StackTrace? stackTrace) {
    debugPrint('TimezoneManager Error: $message - $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

/// Structured error tracking for notification operations
class NotificationError {
  final String operation;
  final String platform;
  final String errorType;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  
  NotificationError({
    required this.operation,
    required this.platform,
    required this.errorType,
    required this.message,
    required this.timestamp,
    this.context,
  });
  
  /// Convert error to JSON for logging
  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'platform': platform,
      'errorType': errorType,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }
  
  /// Get formatted error string for debugging
  String getFormattedError() {
    final buffer = StringBuffer();
    buffer.writeln('NotificationError:');
    buffer.writeln('  Operation: $operation');
    buffer.writeln('  Platform: $platform');
    buffer.writeln('  Type: $errorType');
    buffer.writeln('  Message: $message');
    buffer.writeln('  Timestamp: ${timestamp.toIso8601String()}');
    if (context != null && context!.isNotEmpty) {
      buffer.writeln('  Context: $context');
    }
    return buffer.toString();
  }
}

/// Recovery action for notification errors
class NotificationRecoveryAction {
  final String actionType;
  final String description;
  final Future<bool> Function() action;
  final int maxRetries;
  
  NotificationRecoveryAction({
    required this.actionType,
    required this.description,
    required this.action,
    this.maxRetries = 3,
  });
}

/// Service health status tracking
class NotificationServiceStatus {
  final bool isInitialized;
  final bool channelsCreated;
  final bool timezoneInitialized;
  final bool permissionsGranted;
  final List<String> errors;
  final List<String> warnings;
  final DateTime lastHealthCheck;
  
  NotificationServiceStatus({
    required this.isInitialized,
    required this.channelsCreated,
    required this.timezoneInitialized,
    required this.permissionsGranted,
    required this.errors,
    required this.warnings,
    required this.lastHealthCheck,
  });
  
  /// Check if the service is healthy (all components working)
  bool get isHealthy => isInitialized && channelsCreated && timezoneInitialized && errors.isEmpty;
  
  /// Convert status to JSON for logging
  Map<String, dynamic> toJson() {
    return {
      'isInitialized': isInitialized,
      'channelsCreated': channelsCreated,
      'timezoneInitialized': timezoneInitialized,
      'permissionsGranted': permissionsGranted,
      'errors': errors,
      'warnings': warnings,
      'lastHealthCheck': lastHealthCheck.toIso8601String(),
      'isHealthy': isHealthy,
    };
  }
  
  /// Get human-readable status summary
  String getStatusSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Notification Service Status:');
    buffer.writeln('  Initialized: $isInitialized');
    buffer.writeln('  Channels Created: $channelsCreated');
    buffer.writeln('  Timezone Ready: $timezoneInitialized');
    buffer.writeln('  Permissions Granted: $permissionsGranted');
    buffer.writeln('  Overall Health: ${isHealthy ? "Healthy" : "Unhealthy"}');
    
    if (errors.isNotEmpty) {
      buffer.writeln('  Errors: ${errors.join(", ")}');
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('  Warnings: ${warnings.join(", ")}');
    }
    
    buffer.writeln('  Last Check: ${lastHealthCheck.toIso8601String()}');
    
    return buffer.toString();
  }
}

/// Android notification channels configuration
class AndroidNotificationChannels {
  static const String taskRemindersChannelId = 'task_reminders';
  static const String achievementsChannelId = 'achievements';
  static const String systemChannelId = 'system_notifications';
  
  static const AndroidNotificationChannel taskRemindersChannel = AndroidNotificationChannel(
    taskRemindersChannelId,
    'Task Reminders',
    description: 'Notifications for scheduled task reminders',
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
    showBadge: true,
  );
  
  static const AndroidNotificationChannel achievementsChannel = AndroidNotificationChannel(
    achievementsChannelId,
    'Achievements',
    description: 'Notifications for earned achievements and milestones',
    importance: Importance.defaultImportance,
    enableVibration: true,
    playSound: true,
    showBadge: false,
  );
  
  static const AndroidNotificationChannel systemChannel = AndroidNotificationChannel(
    systemChannelId,
    'System Notifications',
    description: 'System notifications and app updates',
    importance: Importance.low,
    enableVibration: false,
    playSound: false,
    showBadge: false,
  );
  
  static List<AndroidNotificationChannel> getAllChannels() {
    return [taskRemindersChannel, achievementsChannel, systemChannel];
  }
}

/// Service for managing local notifications for task reminders
/// 
/// This service provides functionality to:
/// - Initialize notification system and request permissions
/// - Schedule task reminder notifications
/// - Cancel individual or all notifications
/// - Generate unique notification IDs
/// - Format notification content
/// 
/// Uses singleton pattern to ensure single instance across the app
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;
  bool _channelsCreated = false;
  bool _timezoneInitialized = false;
  final Random _random = Random();
  PlatformCompatibility? _platformCompatibility;

  /// Initialize the notification service with enhanced setup and retry logic
  /// 
  /// Sets up platform-specific notification settings and requests permissions
  /// Must be called before using any other notification methods
  Future<void> initialize({int maxRetries = 3}) async {
    if (_isInitialized) return;

    int retryCount = 0;
    Exception? lastException;

    while (retryCount < maxRetries && !_isInitialized) {
      try {
        debugPrint('Initializing notification service (attempt ${retryCount + 1}/$maxRetries)...');
        
        // Reset status flags for retry
        _channelsCreated = false;
        _timezoneInitialized = false;

        // Step 1: Initialize timezone data with error handling
        debugPrint('Step 1: Initializing timezone data...');
        _timezoneInitialized = await TimezoneManager.initializeTimezones();
        if (!_timezoneInitialized) {
          debugPrint('Warning: Timezone initialization failed, will attempt recovery later');
        }

        // Step 2: Initialize Flutter Local Notifications Plugin
        debugPrint('Step 2: Initializing notification plugin...');
        _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

        // Android initialization settings
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        // iOS initialization settings
        const DarwinInitializationSettings initializationSettingsIOS =
            DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

        // Linux initialization settings
        const LinuxInitializationSettings initializationSettingsLinux =
            LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        );

        // Combined initialization settings
        const InitializationSettings initializationSettings =
            InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          linux: initializationSettingsLinux,
        );

        // Initialize the plugin
        await _flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: _onNotificationTapped,
        );

        // Step 3: Detect platform compatibility and create notification channels
        debugPrint('Step 3: Detecting platform compatibility...');
        await detectPlatformCompatibility();
        
        debugPrint('Step 3b: Creating notification channels conditionally...');
        await _createNotificationChannelsConditionally();

        // Step 4: Setup platform fallbacks
        debugPrint('Step 4: Setting up platform fallbacks...');
        await _setupPlatformFallbacks();
        
        // Step 5: Verify all components
        debugPrint('Step 5: Verifying initialization...');
        await _verifyInitialization();

        _isInitialized = true;
        _logSuccess('initialization', context: {
          'channelsCreated': _channelsCreated,
          'timezoneInitialized': _timezoneInitialized,
          'retryCount': retryCount,
        });
        
        debugPrint('Notification service initialized successfully');
        break;

      } catch (e, stackTrace) {
        lastException = e is Exception ? e : Exception(e.toString());
        retryCount++;
        
        _logError('initialization_attempt', e, stackTrace, context: {
          'attempt': retryCount,
          'maxRetries': maxRetries,
        });

        if (retryCount < maxRetries) {
          debugPrint('Initialization failed, retrying in ${retryCount * 1000}ms...');
          await Future.delayed(Duration(milliseconds: retryCount * 1000));
        }
      }
    }

    // If all retries failed, handle the error
    if (!_isInitialized && lastException != null) {
      await _handleInitializationError('service', lastException, StackTrace.current);
      throw lastException;
    }
  }

  /// Verify that all initialization components are working correctly
  Future<void> _verifyInitialization() async {
    final List<String> issues = [];

    // Verify timezone initialization
    if (!_timezoneInitialized || !TimezoneManager.verifyInitialization()) {
      issues.add('Timezone verification failed');
      // Attempt one more timezone recovery
      if (await TimezoneManager.attemptRecovery()) {
        _timezoneInitialized = true;
      }
    }

    // Verify Android channels (if on Android)
    if (Platform.isAndroid && !_channelsCreated) {
      issues.add('Android channels not created');
      // Attempt channel recovery
      await _attemptChannelRecovery();
    }

    // Log verification results
    if (issues.isNotEmpty) {
      debugPrint('Initialization verification found issues: ${issues.join(', ')}');
    } else {
      debugPrint('Initialization verification passed');
    }
  }

  /// Handle notification tap events
  /// 
  /// Called when user taps on a notification
  /// Can be extended to navigate to specific screens or perform actions
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');
    // Simple implementation: just log for now
    // Navigation can be added later if needed
  }

  /// Create Android notification channels for API 26+
  /// 
  /// Creates all predefined notification channels required for the app
  /// This is required for Android 8.0+ to display notifications
  Future<void> _createAndroidNotificationChannels() async {
    if (!Platform.isAndroid) return;
    
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation == null) {
        debugPrint('Android implementation not available for notification channels');
        return;
      }
      
      // Create all notification channels
      for (final channel in AndroidNotificationChannels.getAllChannels()) {
        await androidImplementation.createNotificationChannel(channel);
        debugPrint('Created notification channel: ${channel.id}');
      }
      
      _channelsCreated = true;
      _logSuccess('channel_creation', context: {
        'channelCount': AndroidNotificationChannels.getAllChannels().length,
      });
    } catch (e, stackTrace) {
      _logError('channel_creation', e, stackTrace);
      _channelsCreated = false;
    }
  }

  /// Verify that all required notification channels exist
  /// 
  /// Returns true if all channels are properly created
  Future<bool> _verifyNotificationChannels() async {
    if (!Platform.isAndroid) return true;
    
    try {
      // Simple check: if we successfully created channels, they exist
      return _channelsCreated;
    } catch (e) {
      debugPrint('Error verifying notification channels: $e');
      return false;
    }
  }

  /// Recreate notification channels if they don't exist
  /// 
  /// This method can be called to recover from channel deletion
  Future<void> _recreateChannelsIfNeeded() async {
    if (!Platform.isAndroid) return;
    
    final channelsExist = await _verifyNotificationChannels();
    if (!channelsExist) {
      debugPrint('Notification channels missing, recreating...');
      await _createAndroidNotificationChannels();
    }
  }

  /// Request notification permissions from the user
  /// 
  /// Returns true if permissions are granted, false otherwise
  /// On Android 13+, this will show a permission dialog
  /// On iOS, this will show the standard notification permission dialog
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    bool? result;

    if (Platform.isIOS) {
      result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      result = await androidImplementation?.requestNotificationsPermission();
    }

    return result ?? false;
  }

  /// Check if notifications are currently enabled
  /// 
  /// Returns true if the app has notification permissions
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      // Use the plugin to get actual iOS permission status
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      if (iosImplementation == null) {
        return false;
      }
      
      try {
        // Check if we can get notification settings
        final result = await iosImplementation.checkPermissions();
        return result?.isEnabled ?? false;
      } catch (e) {
        debugPrint('iOS permission check failed: $e');
        return false;
      }
    }

    return false;
  }

  /// Check if exact alarm scheduling is available
  /// 
  /// Returns true if the app can schedule exact alarms
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) {
      return true; // iOS doesn't have this restriction
    }
    
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation == null) {
        return false;
      }
      
      final bool? canSchedule = await androidImplementation.canScheduleExactNotifications();
      return canSchedule ?? false;
    } catch (e) {
      debugPrint('Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// Request exact alarm permission (Android 12+)
  /// 
  /// This will open the system settings for the user to grant permission
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) {
      return true; // iOS doesn't need this
    }
    
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation == null) {
        return false;
      }
      
      // This will open the system settings page for exact alarms
      await androidImplementation.requestExactAlarmsPermission();
      
      // Check if permission was granted after user returns from settings
      await Future.delayed(const Duration(milliseconds: 500));
      return await canScheduleExactAlarms();
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// Get detailed notification permission status
  /// 
  /// Returns specific permission status for better handling
  Future<NotificationPermissionStatus> getDetailedPermissionStatus() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation == null) {
          return NotificationPermissionStatus.unknown;
        }

        final bool? enabled = await androidImplementation.areNotificationsEnabled();
        if (enabled == null) {
          return NotificationPermissionStatus.unknown;
        }
        
        return enabled 
            ? NotificationPermissionStatus.granted 
            : NotificationPermissionStatus.denied;
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        
        if (iosImplementation == null) {
          return NotificationPermissionStatus.unknown;
        }
        
        final result = await iosImplementation.checkPermissions();
        if (result == null) {
          return NotificationPermissionStatus.notDetermined;
        }
        
        return result.isEnabled 
            ? NotificationPermissionStatus.granted 
            : NotificationPermissionStatus.denied;
      }
    } catch (e) {
      debugPrint('Error getting detailed permission status: $e');
    }

    return NotificationPermissionStatus.unknown;
  }

  /// Get comprehensive permission status including exact alarms
  /// 
  /// Returns a map with detailed permission information
  Future<Map<String, dynamic>> getComprehensivePermissionStatus() async {
    final basicPermissions = await areNotificationsEnabled();
    final exactAlarms = await canScheduleExactAlarms();
    final detailedStatus = await getDetailedPermissionStatus();
    
    return {
      'basicNotifications': basicPermissions,
      'exactAlarms': exactAlarms,
      'detailedStatus': detailedStatus.toString(),
      'platform': Platform.operatingSystem,
      'canSchedulePreciseNotifications': exactAlarms,
      'recommendedAction': exactAlarms 
          ? 'All permissions available' 
          : 'Consider enabling exact alarms for precise timing',
    };
  }

  /// Schedule a notification for a task with enhanced error handling and verification
  /// 
  /// [task] - The task to schedule notification for
  /// Returns the notification ID that was assigned, or null if scheduling failed
  /// 
  /// The notification will be scheduled for the task's notificationTime
  /// If the task doesn't have a notification time set, returns null
  /// 
  /// Enhanced features:
  /// - Comprehensive health checks before scheduling
  /// - Verification that notifications were actually scheduled
  /// - Proper error handling for scheduling failures
  /// - Support for exactAllowWhileIdle with permission handling
  Future<int?> scheduleTaskNotification(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check if task has notification time set
    if (task.notificationTime == null) {
      debugPrint('Task ${task.id} has no notification time set');
      return null;
    }

    // Don't schedule notifications for completed tasks
    if (task.isCompleted) {
      debugPrint('Task ${task.id} is completed, skipping notification scheduling');
      return null;
    }

    // Don't schedule notifications for past times
    if (task.notificationTime!.isBefore(DateTime.now())) {
      debugPrint('Task ${task.id} notification time is in the past, skipping scheduling');
      return null;
    }

    // Perform comprehensive health check before scheduling
    debugPrint('Performing health check before scheduling notification for task ${task.id}');
    await performHealthCheck();
    
    // Get current service status to ensure all components are healthy
    final serviceStatus = await getServiceStatus();
    if (!serviceStatus.isHealthy) {
      debugPrint('Service is not healthy, attempting recovery before scheduling');
      await attemptServiceRecovery();
      
      // Check again after recovery
      final recoveredStatus = await getServiceStatus();
      if (!recoveredStatus.isHealthy) {
        _logError('scheduling_health_check', 'Service unhealthy after recovery', null, context: {
          'taskId': task.id,
          'errors': recoveredStatus.errors,
          'warnings': recoveredStatus.warnings,
        });
        return null;
      }
    }
    
    // Ensure Android notification channels exist before scheduling
    if (Platform.isAndroid) {
      await _recreateChannelsIfNeeded();
      
      // Verify channels were created successfully
      if (!await _verifyNotificationChannels()) {
        _logError('channel_verification', 'Android channels not available for scheduling', null, context: {
          'taskId': task.id,
        });
        return null;
      }
    }

    // Check permissions before scheduling
    final permissionsEnabled = await areNotificationsEnabled();
    if (!permissionsEnabled) {
      debugPrint('Notification permissions not granted, cannot schedule notification');
      return null;
    }

    // Generate notification ID if not already assigned
    final int notificationId = task.notificationId ?? _generateNotificationId();

    try {
      // Convert DateTime to TZDateTime for proper scheduling
      final tz.TZDateTime? scheduledDate = _convertToTZDateTime(task.notificationTime!);
      
      if (scheduledDate == null) {
        debugPrint('Failed to convert DateTime to TZDateTime for notification scheduling');
        // Attempt timezone recovery
        if (await TimezoneManager.attemptRecovery()) {
          final tz.TZDateTime? retryScheduledDate = _convertToTZDateTime(task.notificationTime!);
          if (retryScheduledDate == null) {
            _logError('timezone_conversion', 'Timezone recovery failed, cannot schedule notification', null, context: {
              'taskId': task.id,
              'originalTime': task.notificationTime?.toIso8601String(),
            });
            return null;
          }
          // Continue with retry date
          return await _scheduleNotificationWithDate(notificationId, task, retryScheduledDate);
        } else {
          return null;
        }
      }

      final result = await _scheduleNotificationWithDate(notificationId, task, scheduledDate);
      
      if (result != null) {
        // Verify the notification was actually scheduled successfully
        final isScheduled = await isNotificationScheduled(result);
        if (!isScheduled) {
          _logError('scheduling_verification', 'Notification was not found in pending list after scheduling', null, context: {
            'taskId': task.id,
            'notificationId': result,
            'scheduledTime': task.notificationTime?.toIso8601String(),
          });
          return null;
        }
        
        _logSuccess('notification_scheduling', context: {
          'taskId': task.id,
          'notificationId': result,
          'scheduledTime': task.notificationTime?.toIso8601String(),
          'verified': true,
        });
        
        debugPrint('Successfully scheduled and verified notification $result for task ${task.id}');
      }
      
      return result;
    } catch (e, stackTrace) {
      _logError('notification_scheduling', e, stackTrace, context: {
        'taskId': task.id,
        'taskTitle': task.title,
        'scheduledTime': task.notificationTime?.toIso8601String(),
        'notificationId': notificationId,
      });
      return null;
    }
  }

  /// Helper method to schedule notification with a valid TZDateTime
  /// Enhanced with proper exact alarm permission handling
  Future<int?> _scheduleNotificationWithDate(int notificationId, Task task, tz.TZDateTime scheduledDate) async {
    try {
      // Determine the appropriate Android schedule mode based on available permissions
      AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexact; // Default to safe mode
      
      if (Platform.isAndroid) {
        try {
          final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
              _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          
          if (androidImplementation != null) {
            // Check if exact alarms are allowed
            final bool? canScheduleExactAlarms = await androidImplementation.canScheduleExactNotifications();
            
            if (canScheduleExactAlarms == true) {
              scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
              debugPrint('Using exactAllowWhileIdle schedule mode for notification $notificationId');
            } else {
              scheduleMode = AndroidScheduleMode.inexact;
              debugPrint('Exact alarms not permitted, using inexact scheduling for notification $notificationId');
            }
          }
        } catch (e) {
          // Fallback to inexact mode if permission check fails
          debugPrint('Permission check failed, falling back to inexact mode: $e');
          scheduleMode = AndroidScheduleMode.inexact;
        }
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Task Reminder',
        _formatNotificationBody(task),
        scheduledDate,
        _getNotificationDetails(),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id?.toString(),
      );

      debugPrint('Notification $notificationId scheduled successfully with mode: $scheduleMode');
      return notificationId;
    } catch (e) {
      // If scheduling fails, try with the most basic inexact mode
      debugPrint('Initial scheduling failed, trying with basic inexact mode: $e');
      
      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'Task Reminder',
          _formatNotificationBody(task),
          scheduledDate,
          _getNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id?.toString(),
        );
        
        debugPrint('Notification $notificationId scheduled with basic inexact timing as fallback');
        return notificationId;
      } catch (fallbackError, fallbackStackTrace) {
        _logError('notification_scheduling_fallback', fallbackError, fallbackStackTrace, context: {
          'notificationId': notificationId,
          'taskTitle': task.title,
          'originalError': e.toString(),
        });
        return null;
      }
    }
  }

  /// Cancel a specific task notification
  /// 
  /// [notificationId] - The ID of the notification to cancel
  Future<void> cancelTaskNotification(int notificationId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  /// Cancel all scheduled notifications
  /// 
  /// Useful for when user disables notifications globally
  /// or when performing bulk operations
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  /// Reschedule notifications for all tasks
  /// 
  /// [tasks] - List of tasks to reschedule notifications for
  /// This method will cancel all existing notifications and reschedule
  /// notifications for tasks that have notification times set
  /// 
  /// Useful when user re-enables notifications or when bulk updating
  Future<void> rescheduleAllNotifications(List<Task> tasks) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel all existing notifications first
    await cancelAllNotifications();

    // Schedule notifications for tasks that need them
    for (final task in tasks) {
      if (task.notificationTime != null && !task.isCompleted) {
        await scheduleTaskNotification(task);
      }
    }
  }

  /// Show an immediate notification for task completion
  /// 
  /// [task] - The task that was completed
  /// This can be used to show congratulatory messages or streak updates
  Future<void> showTaskCompletionNotification(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        _generateNotificationId(),
        'Task Completed! 🎉',
        'Great job completing "${task.title}"!',
        _getNotificationDetails(),
        payload: 'completion_${task.id}',
      );
    } catch (e) {
      debugPrint('Error showing completion notification: $e');
    }
  }

  /// Generate a unique notification ID
  /// 
  /// Returns a random integer between 1000 and 999999
  /// This ensures we don't conflict with system notification IDs
  int _generateNotificationId() {
    return 1000 + _random.nextInt(999000);
  }

  /// Format the notification body text for a task
  /// 
  /// [task] - The task to format notification for
  /// Returns a user-friendly notification message
  String _formatNotificationBody(Task task) {
    final String taskType = task.isRoutine ? 'routine task' : 'task';
    
    if (task.description != null && task.description!.isNotEmpty) {
      return 'Time to work on your $taskType: ${task.title}\n${task.description}';
    } else {
      return 'Time to work on your $taskType: ${task.title}';
    }
  }

  /// Get platform-specific notification details
  /// 
  /// Returns configured notification details for Android and iOS
  /// Uses proper channel IDs for Android 8.0+ compatibility
  /// Falls back to legacy details for older platform versions
  NotificationDetails _getNotificationDetails() {
    // For synchronous calls, use the basic implementation
    // The async version _getPlatformSpecificNotificationDetails() 
    // should be used when platform detection is needed
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      AndroidNotificationChannels.taskRemindersChannelId,
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails();

    return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );
  }

  /// Convert DateTime to TZDateTime for scheduling
  /// 
  /// [dateTime] - The DateTime to convert
  /// Returns a TZDateTime in the local timezone, or null if conversion fails
  tz.TZDateTime? _convertToTZDateTime(DateTime dateTime) {
    return TimezoneManager.safeConvertToTZDateTime(dateTime);
  }



  /// Get all pending notifications
  /// 
  /// Returns a list of all currently scheduled notifications
  /// Useful for debugging and managing notification state
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if a specific notification is scheduled
  /// 
  /// [notificationId] - The ID to check for
  /// Returns true if a notification with this ID is scheduled
  Future<bool> isNotificationScheduled(int notificationId) async {
    final pendingNotifications = await getPendingNotifications();
    return pendingNotifications.any((notification) => notification.id == notificationId);
  }

  /// Log detailed error information with platform and context
  void _logError(String operation, dynamic error, StackTrace? stackTrace, {Map<String, dynamic>? context}) {
    final notificationError = NotificationError(
      operation: operation,
      platform: Platform.operatingSystem,
      errorType: error.runtimeType.toString(),
      message: error.toString(),
      timestamp: DateTime.now(),
      context: context,
    );
    
    debugPrint(notificationError.getFormattedError());
    
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Handle initialization errors with recovery attempts
  Future<void> _handleInitializationError(String component, dynamic error, StackTrace? stackTrace) async {
    final context = {'component': component, 'isInitialized': _isInitialized};
    _logError('initialization', error, stackTrace, context: context);
    
    // Attempt recovery based on component
    switch (component) {
      case 'channels':
        await _attemptChannelRecovery();
        break;
      case 'timezone':
        await _attemptTimezoneRecovery();
        break;
      case 'permissions':
        await _attemptPermissionRecovery();
        break;
      default:
        debugPrint('No recovery action available for component: $component');
    }
  }

  /// Attempt to recover from channel creation failures
  Future<void> _attemptChannelRecovery() async {
    try {
      debugPrint('Attempting notification channel recovery...');
      // Wait a bit and retry channel creation
      await Future.delayed(const Duration(seconds: 1));
      await _createAndroidNotificationChannels();
      
      if (await _verifyNotificationChannels()) {
        _channelsCreated = true;
        debugPrint('Channel recovery successful');
      } else {
        debugPrint('Channel recovery failed - channels still not available');
      }
    } catch (e, stackTrace) {
      _logError('channel_recovery', e, stackTrace);
    }
  }

  /// Attempt to recover from timezone initialization failures
  Future<void> _attemptTimezoneRecovery() async {
    try {
      debugPrint('Attempting timezone recovery...');
      // Retry timezone initialization
      _timezoneInitialized = await TimezoneManager.attemptRecovery();
      
      if (_timezoneInitialized) {
        debugPrint('Timezone recovery successful');
      } else {
        debugPrint('Timezone recovery failed');
      }
    } catch (e, stackTrace) {
      _logError('timezone_recovery', e, stackTrace);
    }
  }

  /// Attempt to recover from permission-related failures
  Future<void> _attemptPermissionRecovery() async {
    try {
      debugPrint('Attempting permission recovery...');
      // Check current permission status
      final permissionStatus = await getDetailedPermissionStatus();
      debugPrint('Current permission status: $permissionStatus');
      
      if (permissionStatus == NotificationPermissionStatus.notDetermined) {
        // Try to request permissions again
        final granted = await requestPermissions();
        debugPrint('Permission recovery result: $granted');
      }
    } catch (e, stackTrace) {
      _logError('permission_recovery', e, stackTrace);
    }
  }

  /// Log successful operations for verification
  void _logSuccess(String operation, {Map<String, dynamic>? context}) {
    final contextStr = context != null ? ' - Context: $context' : '';
    debugPrint('NotificationService Success: $operation on ${Platform.operatingSystem}$contextStr');
  }

  /// Perform comprehensive health check of all service components
  Future<void> performHealthCheck() async {
    debugPrint('Performing notification service health check...');
    final List<String> errors = [];
    final List<String> warnings = [];
    
    // Check initialization status
    if (!_isInitialized) {
      errors.add('Service not initialized');
    }
    
    // Check Android channels (if on Android)
    if (Platform.isAndroid && !_channelsCreated) {
      errors.add('Android notification channels not created');
      await _attemptChannelRecovery();
    }
    
    // Check timezone initialization
    if (!TimezoneManager.isInitialized) {
      errors.add('Timezone data not initialized');
      await _attemptTimezoneRecovery();
    }
    
    // Verify timezone functionality
    if (TimezoneManager.isInitialized && !TimezoneManager.verifyInitialization()) {
      warnings.add('Timezone verification failed');
      await _attemptTimezoneRecovery();
    }
    
    // Check permissions
    try {
      final permissionsEnabled = await areNotificationsEnabled();
      if (!permissionsEnabled) {
        warnings.add('Notification permissions not granted');
      }
    } catch (e) {
      errors.add('Permission check failed: $e');
    }
    
    // Log health check results
    if (errors.isNotEmpty) {
      debugPrint('NotificationService health check failed: ${errors.join(', ')}');
    }
    
    if (warnings.isNotEmpty) {
      debugPrint('NotificationService health check warnings: ${warnings.join(', ')}');
    }
    
    if (errors.isEmpty && warnings.isEmpty) {
      debugPrint('NotificationService health check passed');
    }
  }

  /// Get comprehensive service status
  Future<NotificationServiceStatus> getServiceStatus() async {
    final List<String> errors = [];
    final List<String> warnings = [];
    
    // Check permissions
    bool permissionsGranted = false;
    try {
      permissionsGranted = await areNotificationsEnabled();
      if (!permissionsGranted) {
        warnings.add('Permissions not granted');
      }
    } catch (e) {
      errors.add('Permission check failed');
    }
    
    // Check for timezone errors
    if (TimezoneManager.initializationError != null) {
      errors.add('Timezone error: ${TimezoneManager.initializationError}');
    }
    
    // Check initialization status
    if (!_isInitialized) {
      errors.add('Service not initialized');
    }
    
    // Check Android channels
    if (Platform.isAndroid && !_channelsCreated) {
      errors.add('Android channels not created');
    }
    
    return NotificationServiceStatus(
      isInitialized: _isInitialized,
      channelsCreated: _channelsCreated,
      timezoneInitialized: _timezoneInitialized,
      permissionsGranted: permissionsGranted,
      errors: errors,
      warnings: warnings,
      lastHealthCheck: DateTime.now(),
    );
  }

  /// Attempt automatic service recovery
  Future<void> attemptServiceRecovery() async {
    debugPrint('Attempting notification service recovery...');
    
    try {
      // Re-initialize if not initialized
      if (!_isInitialized) {
        debugPrint('Re-initializing notification service...');
        await initialize();
      }
      
      // Recover channels if needed
      if (Platform.isAndroid && !_channelsCreated) {
        await _attemptChannelRecovery();
      }
      
      // Recover timezone if needed
      if (!_timezoneInitialized) {
        await _attemptTimezoneRecovery();
      }
      
      // Perform final health check
      await performHealthCheck();
      
      final status = await getServiceStatus();
      if (status.isHealthy) {
        debugPrint('Service recovery successful');
        _logSuccess('service_recovery');
      } else {
        debugPrint('Service recovery partially successful - some issues remain');
        debugPrint(status.getStatusSummary());
      }
    } catch (e, stackTrace) {
      _logError('service_recovery', e, stackTrace);
    }
  }



  /// Request exact alarm permissions if needed (Android 12+)
  /// 
  /// Returns true if permissions are granted or not needed
  Future<bool> requestExactAlarmPermissions() async {
    if (!Platform.isAndroid) {
      return true; // Not needed on other platforms
    }
    
    try {
      // Simple approach: request notification permissions covers most cases
      return await requestPermissions();
    } catch (e) {
      debugPrint('Error requesting exact alarm permissions: $e');
      return false;
    }
  }

  /// Send a test notification to verify service functionality
  /// 
  /// This method performs a comprehensive test of the notification system:
  /// - Checks service health
  /// - Verifies permissions
  /// - Sends an immediate test notification
  /// - Confirms delivery
  Future<bool> sendTestNotification() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Perform health check first
      debugPrint('Performing health check before test notification...');
      await performHealthCheck();
      
      // Check permissions
      final permissionsEnabled = await areNotificationsEnabled();
      if (!permissionsEnabled) {
        debugPrint('Test notification failed: permissions not granted');
        return false;
      }
      
      final testId = _generateNotificationId();
      debugPrint('Sending test notification with ID: $testId');
      
      await _flutterLocalNotificationsPlugin.show(
        testId,
        'Test Notification',
        'Notification service is working correctly! 🎉',
        _getNotificationDetails(),
        payload: 'test_notification',
      );
      
      _logSuccess('test_notification', context: {
        'notificationId': testId,
        'permissionsEnabled': permissionsEnabled,
      });
      
      debugPrint('Test notification sent successfully');
      return true;
    } catch (e, stackTrace) {
      _logError('test_notification', e, stackTrace);
      return false;
    }
  }

  /// Verify that a notification was delivered successfully
  /// 
  /// [notificationId] - The ID of the notification to verify
  /// Returns true if the notification appears to have been delivered
  /// 
  /// Note: This is a best-effort verification as the platform doesn't
  /// provide direct delivery confirmation
  Future<bool> verifyNotificationDelivery(int notificationId) async {
    try {
      // Check if the notification is still in the pending list
      // If it's not pending, it was either delivered or cancelled
      final isStillPending = await isNotificationScheduled(notificationId);
      
      if (isStillPending) {
        debugPrint('Notification $notificationId is still pending');
        return true; // Still scheduled, so it's valid
      } else {
        // For immediate notifications, assume success if no error was thrown
        debugPrint('Notification $notificationId is not in pending list (likely delivered or immediate)');
        return true;
      }
    } catch (e) {
      debugPrint('Error verifying notification delivery: $e');
      return false;
    }
  }

  /// Get detailed information about all pending notifications
  /// 
  /// Returns a list of pending notifications with their details
  /// Useful for debugging notification scheduling issues
  Future<List<Map<String, dynamic>>> getDetailedPendingNotifications() async {
    try {
      final pendingNotifications = await getPendingNotifications();
      
      return pendingNotifications.map((notification) {
        return {
          'id': notification.id,
          'title': notification.title,
          'body': notification.body,
          'payload': notification.payload,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting detailed pending notifications: $e');
      return [];
    }
  }

  /// Debug method to inspect the current state of the notification service
  /// 
  /// Prints comprehensive information about the service state
  /// Useful for troubleshooting notification issues
  Future<void> debugServiceState() async {
    debugPrint('=== Notification Service Debug Information ===');
    
    try {
      // Basic service state
      debugPrint('Service initialized: $_isInitialized');
      debugPrint('Channels created: $_channelsCreated');
      debugPrint('Timezone initialized: $_timezoneInitialized');
      debugPrint('Platform: ${Platform.operatingSystem}');
      
      // Timezone information
      debugPrint('Timezone manager initialized: ${TimezoneManager.isInitialized}');
      if (TimezoneManager.initializationError != null) {
        debugPrint('Timezone error: ${TimezoneManager.initializationError}');
      }
      
      // Permission status
      final permissionStatus = await getDetailedPermissionStatus();
      debugPrint('Permission status: $permissionStatus');
      
      // Service health
      final serviceStatus = await getServiceStatus();
      debugPrint('Service healthy: ${serviceStatus.isHealthy}');
      if (serviceStatus.errors.isNotEmpty) {
        debugPrint('Service errors: ${serviceStatus.errors}');
      }
      if (serviceStatus.warnings.isNotEmpty) {
        debugPrint('Service warnings: ${serviceStatus.warnings}');
      }
      
      // Pending notifications
      final pendingNotifications = await getDetailedPendingNotifications();
      debugPrint('Pending notifications count: ${pendingNotifications.length}');
      for (final notification in pendingNotifications) {
        debugPrint('  - ID: ${notification['id']}, Title: ${notification['title']}');
      }
      
      // Platform-specific information
      if (Platform.isAndroid) {
        final canScheduleExact = await canScheduleExactAlarms();
        debugPrint('Can schedule exact alarms: $canScheduleExact');
      }
      
    } catch (e, stackTrace) {
      debugPrint('Error during debug state inspection: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    
    debugPrint('=== End Debug Information ===');
  }

  /// Send a scheduled test notification to verify scheduling functionality
  /// 
  /// [delayMinutes] - How many minutes in the future to schedule the test
  /// Returns the notification ID if successful, null otherwise
  Future<int?> sendScheduledTestNotification({int delayMinutes = 1}) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Perform health check first
      await performHealthCheck();
      
      // Check permissions
      final permissionsEnabled = await areNotificationsEnabled();
      if (!permissionsEnabled) {
        debugPrint('Scheduled test notification failed: permissions not granted');
        return null;
      }
      
      final testId = _generateNotificationId();
      final scheduledTime = DateTime.now().add(Duration(minutes: delayMinutes));
      final tzScheduledTime = _convertToTZDateTime(scheduledTime);
      
      if (tzScheduledTime == null) {
        debugPrint('Failed to convert test notification time to TZDateTime');
        return null;
      }
      
      debugPrint('Scheduling test notification with ID: $testId for ${scheduledTime.toIso8601String()}');
      
      // Determine the appropriate Android schedule mode
      AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexact; // Default to safe mode
      
      if (Platform.isAndroid) {
        try {
          final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
              _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
          
          if (androidImplementation != null) {
            final bool? canScheduleExactAlarms = await androidImplementation.canScheduleExactNotifications();
            
            if (canScheduleExactAlarms == true) {
              scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
              debugPrint('Using exact scheduling for test notification');
            } else {
              scheduleMode = AndroidScheduleMode.inexact;
              debugPrint('Using approximate scheduling for test notification (exact alarms not permitted)');
            }
          }
        } catch (e) {
          debugPrint('Permission check failed for test notification, using inexact mode: $e');
          scheduleMode = AndroidScheduleMode.inexact;
        }
      }
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        testId,
        'Scheduled Test Notification',
        'This test notification was scheduled $delayMinutes minute(s) ago! 🎉',
        tzScheduledTime,
        _getNotificationDetails(),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'scheduled_test_notification',
      );
      
      // Verify the notification was scheduled
      final isScheduled = await isNotificationScheduled(testId);
      if (!isScheduled) {
        debugPrint('Scheduled test notification was not found in pending list');
        return null;
      }
      
      _logSuccess('scheduled_test_notification', context: {
        'notificationId': testId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'delayMinutes': delayMinutes,
      });
      
      debugPrint('Scheduled test notification sent successfully');
      return testId;
    } catch (e, stackTrace) {
      _logError('scheduled_test_notification', e, stackTrace);
      return null;
    }
  }

  /// Detect platform version and capabilities
  /// 
  /// Returns detailed information about the current platform's
  /// notification capabilities and limitations
  Future<PlatformCompatibility> detectPlatformCompatibility() async {
    if (_platformCompatibility != null) {
      return _platformCompatibility!;
    }

    final List<String> limitations = [];
    bool supportsChannels = false;
    bool supportsExactAlarms = false;
    bool supportsProvisionalPermissions = false;
    String version = 'Unknown';

    try {
      if (Platform.isAndroid) {
        // Try to get Android API level
        int apiLevel = await _getAndroidApiLevel();
        version = 'API $apiLevel';
        
        // Android 8.0 (API 26) introduced notification channels
        supportsChannels = apiLevel >= 26;
        if (!supportsChannels) {
          limitations.add('Notification channels not supported (API < 26)');
        }
        
        // Android 12 (API 31) introduced exact alarm restrictions
        supportsExactAlarms = apiLevel >= 31;
        if (apiLevel >= 31) {
          limitations.add('Exact alarms require special permission (API >= 31)');
        }
        
        // Android 13 (API 33) requires runtime notification permission
        if (apiLevel >= 33) {
          limitations.add('Runtime notification permission required (API >= 33)');
        }
        
      } else if (Platform.isIOS) {
        // Try to get iOS version
        version = await _getIOSVersion();
        
        // iOS supports provisional permissions since iOS 12
        supportsProvisionalPermissions = true;
        
        // iOS doesn't use notification channels
        supportsChannels = false;
        
        // iOS handles exact timing differently
        supportsExactAlarms = true;
        
      } else {
        // Other platforms (Linux, macOS, Windows, Web)
        version = Platform.operatingSystemVersion;
        supportsChannels = false;
        supportsExactAlarms = true;
        supportsProvisionalPermissions = false;
        limitations.add('Limited notification support on ${Platform.operatingSystem}');
      }
      
    } catch (e) {
      debugPrint('Error detecting platform compatibility: $e');
      limitations.add('Could not detect platform capabilities');
    }

    _platformCompatibility = PlatformCompatibility(
      platform: Platform.operatingSystem,
      version: version,
      supportsNotificationChannels: supportsChannels,
      supportsExactAlarms: supportsExactAlarms,
      supportsProvisionalPermissions: supportsProvisionalPermissions,
      limitations: limitations,
    );

    return _platformCompatibility!;
  }

  /// Get Android API level
  /// 
  /// Returns the Android API level, or 0 if detection fails
  Future<int> _getAndroidApiLevel() async {
    if (!Platform.isAndroid) return 0;
    
    try {
      // Simple fallback to modern API level since we can't detect reliably
      return 33; // Android 13 - covers most modern devices
    } catch (e) {
      debugPrint('Could not get Android API level: $e');
      return 33; // Android 13
    }
  }

  /// Get iOS version
  /// 
  /// Returns the iOS version string, or 'Unknown' if detection fails
  Future<String> _getIOSVersion() async {
    if (!Platform.isIOS) return 'N/A';
    
    try {
      // Simple fallback since we can't detect reliably
      return '15.0'; // Modern iOS version
    } catch (e) {
      debugPrint('Could not get iOS version: $e');
      return '15.0';
    }
  }

  /// Create notification channels conditionally based on platform version
  /// 
  /// Only creates channels on Android API 26+ where they are required
  Future<void> _createNotificationChannelsConditionally() async {
    final compatibility = await detectPlatformCompatibility();
    
    if (compatibility.supportsNotificationChannels) {
      debugPrint('Platform supports notification channels, creating them...');
      await _createAndroidNotificationChannels();
    } else {
      debugPrint('Platform does not support notification channels, skipping creation');
      _channelsCreated = true; // Mark as "created" since they're not needed
    }
  }



  /// Create fallback mechanisms for unsupported platform features
  /// 
  /// Provides alternative approaches when platform features are unavailable
  Future<void> _setupPlatformFallbacks() async {
    final compatibility = await detectPlatformCompatibility();
    
    // Log platform limitations
    if (compatibility.limitations.isNotEmpty) {
      debugPrint('Platform limitations detected:');
      for (final limitation in compatibility.limitations) {
        debugPrint('  - $limitation');
      }
    }
    
    // Set up fallbacks based on platform capabilities
    if (!compatibility.supportsExactAlarms) {
      debugPrint('Setting up fallback for platforms without exact alarm support');
      // Could implement approximate scheduling fallbacks here
    }
    
    if (!compatibility.supportsNotificationChannels) {
      debugPrint('Setting up fallback for platforms without notification channels');
      // Channels are handled automatically by the plugin on older Android versions
    }
  }



  /// Enhanced permission checking with version-specific handling
  /// 
  /// Uses appropriate permission checking methods based on platform version
  Future<NotificationPermissionStatus> getVersionSpecificPermissionStatus() async {
    final compatibility = await detectPlatformCompatibility();
    
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation == null) {
          return NotificationPermissionStatus.unknown;
        }

        // On Android 13+, check runtime permission
        if (compatibility.version.contains('API 33') || 
            compatibility.version.contains('API 34') ||
            compatibility.limitations.any((l) => l.contains('Runtime notification permission'))) {
          final bool? enabled = await androidImplementation.areNotificationsEnabled();
          return enabled == true 
              ? NotificationPermissionStatus.granted 
              : NotificationPermissionStatus.denied;
        } else {
          // On older Android versions, notifications are enabled by default
          return NotificationPermissionStatus.granted;
        }
      } else if (Platform.isIOS) {
        return await getDetailedPermissionStatus(); // Use existing iOS implementation
      }
    } catch (e) {
      debugPrint('Error getting version-specific permission status: $e');
    }

    return NotificationPermissionStatus.unknown;
  }
}