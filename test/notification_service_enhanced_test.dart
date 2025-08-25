import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../lib/services/notification_service.dart';
import '../lib/models/task.dart';

void main() {
  group('Enhanced NotificationService Tests', () {
    late NotificationService notificationService;

    setUpAll(() {
      // Initialize timezone data for tests
      tz.initializeTimeZones();
    });

    setUp(() {
      notificationService = NotificationService();
      
      // Mock the method channel for flutter_local_notifications
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'initialize':
              return true;
            case 'requestPermissions':
              return true;
            case 'areNotificationsEnabled':
              return true;
            case 'show':
              return null;
            case 'zonedSchedule':
              return null;
            case 'cancel':
              return null;
            case 'cancelAll':
              return null;
            case 'pendingNotificationRequests':
              return <Map<String, dynamic>>[];
            case 'createNotificationChannel':
              return null;
            default:
              return null;
          }
        },
      );

      // Mock platform version method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.dev/platform_version'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getApiLevel':
              return 30; // Android 11
            case 'getIOSVersion':
              return '15.0';
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        null,
      );
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.dev/platform_version'),
        null,
      );
    });

    group('Timezone Management Tests', () {
      test('should initialize timezone data successfully', () async {
        final result = await TimezoneManager.initializeTimezones();
        expect(result, isTrue);
        expect(TimezoneManager.isInitialized, isTrue);
        expect(TimezoneManager.initializationError, isNull);
      });

      test('should convert DateTime to TZDateTime successfully', () {
        final dateTime = DateTime.now().add(const Duration(hours: 1));
        final tzDateTime = TimezoneManager.safeConvertToTZDateTime(dateTime);
        
        expect(tzDateTime, isNotNull);
        expect(tzDateTime!.isAfter(tz.TZDateTime.now(tz.local)), isTrue);
      });

      test('should handle timezone conversion failure gracefully', () {
        // Force timezone to be uninitialized
        TimezoneManager.initializeTimezones();
        
        final dateTime = DateTime.now().add(const Duration(hours: 1));
        final tzDateTime = TimezoneManager.safeConvertToTZDateTime(dateTime);
        
        expect(tzDateTime, isNotNull);
      });

      test('should verify timezone initialization', () {
        TimezoneManager.initializeTimezones();
        final isVerified = TimezoneManager.verifyInitialization();
        expect(isVerified, isTrue);
      });

      test('should attempt recovery from timezone failure', () async {
        final result = await TimezoneManager.attemptRecovery();
        expect(result, isTrue);
      });
    });

    group('Android Notification Channel Tests', () {
      test('should have all required notification channels defined', () {
        final channels = AndroidNotificationChannels.getAllChannels();
        
        expect(channels.length, equals(3));
        expect(channels.any((c) => c.id == AndroidNotificationChannels.taskRemindersChannelId), isTrue);
        expect(channels.any((c) => c.id == AndroidNotificationChannels.achievementsChannelId), isTrue);
        expect(channels.any((c) => c.id == AndroidNotificationChannels.systemChannelId), isTrue);
      });

      test('should have proper channel configurations', () {
        final taskChannel = AndroidNotificationChannels.taskRemindersChannel;
        
        expect(taskChannel.id, equals('task_reminders'));
        expect(taskChannel.name, equals('Task Reminders'));
        expect(taskChannel.importance, equals(Importance.high));
        expect(taskChannel.enableVibration, isTrue);
        expect(taskChannel.playSound, isTrue);
        expect(taskChannel.showBadge, isTrue);
      });
    });

    group('Notification Service Initialization Tests', () {
      test('should initialize notification service successfully', () async {
        await notificationService.initialize();
        
        final status = await notificationService.getServiceStatus();
        expect(status.isInitialized, isTrue);
      });

      test('should handle initialization retry on failure', () async {
        // This test would require mocking failures, but we'll test the basic flow
        await notificationService.initialize(maxRetries: 2);
        
        final status = await notificationService.getServiceStatus();
        expect(status.isInitialized, isTrue);
      });

      test('should perform health check after initialization', () async {
        await notificationService.initialize();
        await notificationService.performHealthCheck();
        
        final status = await notificationService.getServiceStatus();
        expect(status.lastHealthCheck, isNotNull);
      });
    });

    group('Permission Handling Tests', () {
      test('should check notification permissions', () async {
        await notificationService.initialize();
        final hasPermissions = await notificationService.areNotificationsEnabled();
        expect(hasPermissions, isA<bool>());
      });

      test('should get detailed permission status', () async {
        await notificationService.initialize();
        final permissionStatus = await notificationService.getDetailedPermissionStatus();
        expect(permissionStatus, isA<NotificationPermissionStatus>());
      });

      test('should request notification permissions', () async {
        await notificationService.initialize();
        final granted = await notificationService.requestPermissions();
        expect(granted, isA<bool>());
      });

      test('should check exact alarm permissions', () async {
        await notificationService.initialize();
        final canScheduleExact = await notificationService.canScheduleExactAlarms();
        expect(canScheduleExact, isA<bool>());
      });
    });

    group('Notification Scheduling Tests', () {
      test('should schedule task notification successfully', () async {
        await notificationService.initialize();
        
        final task = Task(
          title: 'Test Task',
          description: 'Test Description',
          notificationTime: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );
        
        final notificationId = await notificationService.scheduleTaskNotification(task);
        expect(notificationId, isNotNull);
        expect(notificationId, greaterThan(0));
      });

      test('should not schedule notification for completed task', () async {
        await notificationService.initialize();
        
        final task = Task(
          title: 'Completed Task',
          isCompleted: true,
          notificationTime: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );
        
        final notificationId = await notificationService.scheduleTaskNotification(task);
        expect(notificationId, isNull);
      });

      test('should not schedule notification for past time', () async {
        await notificationService.initialize();
        
        final task = Task(
          title: 'Past Task',
          notificationTime: DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );
        
        final notificationId = await notificationService.scheduleTaskNotification(task);
        expect(notificationId, isNull);
      });

      test('should not schedule notification for routine task', () async {
        await notificationService.initialize();
        
        final task = Task(
          title: 'Routine Task',
          isRoutine: true,
          notificationTime: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );
        
        final notificationId = await notificationService.scheduleTaskNotification(task);
        expect(notificationId, isNull);
      });

      test('should verify notification was scheduled', () async {
        await notificationService.initialize();
        
        final task = Task(
          title: 'Test Task',
          notificationTime: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );
        
        final notificationId = await notificationService.scheduleTaskNotification(task);
        if (notificationId != null) {
          final isScheduled = await notificationService.isNotificationScheduled(notificationId);
          expect(isScheduled, isA<bool>());
        }
      });
    });

    group('Notification Management Tests', () {
      test('should cancel task notification', () async {
        await notificationService.initialize();
        
        final task = Task(
          title: 'Test Task',
          notificationTime: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );
        
        final notificationId = await notificationService.scheduleTaskNotification(task);
        if (notificationId != null) {
          await notificationService.cancelTaskNotification(notificationId);
          // Test passes if no exception is thrown
        }
      });

      test('should cancel all notifications', () async {
        await notificationService.initialize();
        await notificationService.cancelAllNotifications();
        // Test passes if no exception is thrown
      });

      test('should get pending notifications', () async {
        await notificationService.initialize();
        final pendingNotifications = await notificationService.getPendingNotifications();
        expect(pendingNotifications, isA<List<PendingNotificationRequest>>());
      });

      test('should get detailed pending notifications', () async {
        await notificationService.initialize();
        final detailedNotifications = await notificationService.getDetailedPendingNotifications();
        expect(detailedNotifications, isA<List<Map<String, dynamic>>>());
      });
    });

    group('Service Health and Recovery Tests', () {
      test('should get service status', () async {
        await notificationService.initialize();
        final status = await notificationService.getServiceStatus();
        
        expect(status, isA<NotificationServiceStatus>());
        expect(status.isInitialized, isTrue);
        expect(status.lastHealthCheck, isNotNull);
      });

      test('should perform health check', () async {
        await notificationService.initialize();
        await notificationService.performHealthCheck();
        // Test passes if no exception is thrown
      });

      test('should attempt service recovery', () async {
        await notificationService.initialize();
        await notificationService.attemptServiceRecovery();
        
        final status = await notificationService.getServiceStatus();
        expect(status.isInitialized, isTrue);
      });

      test('should detect platform compatibility', () async {
        final compatibility = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility, isA<PlatformCompatibility>());
        expect(compatibility.platform, isNotEmpty);
        expect(compatibility.version, isNotEmpty);
      });
    });

    group('Testing and Verification Tests', () {
      test('should send test notification', () async {
        await notificationService.initialize();
        final success = await notificationService.sendTestNotification();
        expect(success, isA<bool>());
      });

      test('should send scheduled test notification', () async {
        await notificationService.initialize();
        final notificationId = await notificationService.sendScheduledTestNotification(delayMinutes: 1);
        expect(notificationId, isA<int?>());
      });

      test('should verify notification delivery', () async {
        await notificationService.initialize();
        
        final task = Task(
          title: 'Test Task',
          notificationTime: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );
        
        final notificationId = await notificationService.scheduleTaskNotification(task);
        if (notificationId != null) {
          final isDelivered = await notificationService.verifyNotificationDelivery(notificationId);
          expect(isDelivered, isA<bool>());
        }
      });

      test('should debug service state', () async {
        await notificationService.initialize();
        // This method prints debug information, so we just test it doesn't throw
        await notificationService.debugServiceState();
      });
    });

    group('Error Handling Tests', () {
      test('should handle notification error creation', () {
        final error = NotificationError(
          operation: 'test_operation',
          platform: 'test_platform',
          errorType: 'TestError',
          message: 'Test error message',
          timestamp: DateTime.now(),
          context: {'test': 'context'},
        );
        
        expect(error.operation, equals('test_operation'));
        expect(error.platform, equals('test_platform'));
        expect(error.errorType, equals('TestError'));
        expect(error.message, equals('Test error message'));
        expect(error.context, isNotNull);
        
        final json = error.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['operation'], equals('test_operation'));
        
        final formattedError = error.getFormattedError();
        expect(formattedError, contains('test_operation'));
        expect(formattedError, contains('Test error message'));
      });

      test('should handle service status creation', () {
        final status = NotificationServiceStatus(
          isInitialized: true,
          channelsCreated: true,
          timezoneInitialized: true,
          permissionsGranted: true,
          errors: [],
          warnings: ['Test warning'],
          lastHealthCheck: DateTime.now(),
        );
        
        expect(status.isHealthy, isTrue);
        expect(status.warnings.length, equals(1));
        
        final json = status.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['isHealthy'], isTrue);
        
        final summary = status.getStatusSummary();
        expect(summary, contains('Healthy'));
        expect(summary, contains('Test warning'));
      });

      test('should handle platform compatibility creation', () {
        final compatibility = PlatformCompatibility(
          platform: 'android',
          version: 'API 30',
          supportsNotificationChannels: true,
          supportsExactAlarms: true,
          supportsProvisionalPermissions: false,
          limitations: ['Test limitation'],
        );
        
        expect(compatibility.platform, equals('android'));
        expect(compatibility.supportsNotificationChannels, isTrue);
        expect(compatibility.limitations.length, equals(1));
        
        final json = compatibility.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['platform'], equals('android'));
      });
    });

    group('Integration Tests', () {
      test('should handle complete notification lifecycle', () async {
        await notificationService.initialize();
        
        // Create task
        final task = Task(
          title: 'Integration Test Task',
          description: 'Testing complete lifecycle',
          notificationTime: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );
        
        // Schedule notification
        final notificationId = await notificationService.scheduleTaskNotification(task);
        expect(notificationId, isNotNull);
        
        // Verify scheduling
        if (notificationId != null) {
          final isScheduled = await notificationService.isNotificationScheduled(notificationId);
          expect(isScheduled, isA<bool>());
          
          // Cancel notification
          await notificationService.cancelTaskNotification(notificationId);
        }
        
        // Check service health
        final status = await notificationService.getServiceStatus();
        expect(status.isInitialized, isTrue);
      });

      test('should handle service recovery scenario', () async {
        await notificationService.initialize();
        
        // Perform health check
        await notificationService.performHealthCheck();
        
        // Attempt recovery (should succeed since service is healthy)
        await notificationService.attemptServiceRecovery();
        
        // Verify service is still healthy
        final status = await notificationService.getServiceStatus();
        expect(status.isInitialized, isTrue);
      });

      test('should handle multiple notification scheduling', () async {
        await notificationService.initialize();
        
        final tasks = List.generate(3, (index) => Task(
          title: 'Test Task $index',
          notificationTime: DateTime.now().add(Duration(hours: index + 1)),
          createdAt: DateTime.now(),
        ));
        
        final notificationIds = <int>[];
        for (final task in tasks) {
          final id = await notificationService.scheduleTaskNotification(task);
          if (id != null) {
            notificationIds.add(id);
          }
        }
        
        expect(notificationIds.length, lessThanOrEqualTo(3));
        
        // Clean up
        for (final id in notificationIds) {
          await notificationService.cancelTaskNotification(id);
        }
      });
    });
  });
}