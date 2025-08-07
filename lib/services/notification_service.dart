import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

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
  final Random _random = Random();

  /// Initialize the notification service
  /// 
  /// Sets up platform-specific notification settings and requests permissions
  /// Must be called before using any other notification methods
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

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

    _isInitialized = true;
  }

  /// Handle notification tap events
  /// 
  /// Called when user taps on a notification
  /// Can be extended to navigate to specific screens or perform actions
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap
    // For now, we'll just print the payload for debugging
    debugPrint('Notification tapped: ${notificationResponse.payload}');
    
    // Future enhancement: Navigate to task details or mark as complete
    // This could be implemented by parsing the payload and using a navigation service
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
      // For iOS, we'll assume notifications are enabled if we got this far
      // In a production app, you might want to use a more sophisticated check
      return true;
    }

    return false;
  }

  /// Schedule a notification for a task
  /// 
  /// [task] - The task to schedule notification for
  /// Returns the notification ID that was assigned, or null if scheduling failed
  /// 
  /// The notification will be scheduled for the task's notificationTime
  /// If the task doesn't have a notification time set, returns null
  Future<int?> scheduleTaskNotification(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check if task has notification time set
    if (task.notificationTime == null) {
      return null;
    }

    // Don't schedule notifications for completed tasks
    if (task.isCompleted) {
      return null;
    }

    // Don't schedule notifications for past times
    if (task.notificationTime!.isBefore(DateTime.now())) {
      return null;
    }

    // Generate notification ID if not already assigned
    final int notificationId = task.notificationId ?? _generateNotificationId();

    try {
      // Convert DateTime to TZDateTime for proper scheduling
      final tz.TZDateTime scheduledDate = _convertToTZDateTime(task.notificationTime!);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Task Reminder',
        _formatNotificationBody(task),
        scheduledDate,
        _getNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id?.toString(),
      );

      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return null;
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
  NotificationDetails _getNotificationDetails() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_reminders',
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
  /// Returns a TZDateTime in the local timezone
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final tz.Location local = tz.local;
    return tz.TZDateTime.from(dateTime, local);
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
}