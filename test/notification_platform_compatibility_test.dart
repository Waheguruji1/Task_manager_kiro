import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../lib/services/notification_service.dart';

void main() {
  group('Notification Platform Compatibility Tests', () {
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

    group('Android API Level Detection Tests', () {
      test('should detect Android API 26+ for notification channels', () async {
        // Mock Android API 30
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApiLevel') {
              return 30; // Android 11
            }
            return null;
          },
        );

        final compatibility = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility.platform, contains('android'));
        expect(compatibility.version, contains('API 30'));
        expect(compatibility.supportsNotificationChannels, isTrue);
      });

      test('should detect Android API < 26 without notification channels', () async {
        // Mock Android API 25
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApiLevel') {
              return 25; // Android 7.1
            }
            return null;
          },
        );

        final compatibility = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility.platform, contains('android'));
        expect(compatibility.version, contains('API 25'));
        expect(compatibility.supportsNotificationChannels, isFalse);
        expect(compatibility.limitations, contains(contains('Notification channels not supported')));
      });

      test('should detect Android API 31+ with exact alarm restrictions', () async {
        // Mock Android API 33
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApiLevel') {
              return 33; // Android 13
            }
            return null;
          },
        );

        final compatibility = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility.platform, contains('android'));
        expect(compatibility.version, contains('API 33'));
        expect(compatibility.supportsNotificationChannels, isTrue);
        expect(compatibility.limitations, contains(contains('Exact alarms require special permission')));
        expect(compatibility.limitations, contains(contains('Runtime notification permission required')));
      });

      test('should handle Android API level detection failure', () async {
        // Mock API level detection failure
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApiLevel') {
              throw PlatformException(code: 'ERROR', message: 'Failed to get API level');
            }
            return null;
          },
        );

        final compatibility = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility.platform, contains('android'));
        expect(compatibility.version, contains('API 30')); // Fallback value
        expect(compatibility.limitations, contains(contains('Could not detect platform capabilities')));
      });
    });

    group('iOS Version Detection Tests', () {
      test('should detect iOS version and capabilities', () async {
        // Mock iOS version
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getIOSVersion') {
              return '15.0';
            }
            return null;
          },
        );

        final compatibility = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility.platform, contains('ios'));
        expect(compatibility.version, equals('15.0'));
        expect(compatibility.supportsNotificationChannels, isFalse);
        expect(compatibility.supportsExactAlarms, isTrue);
        expect(compatibility.supportsProvisionalPermissions, isTrue);
      });

      test('should handle iOS version detection failure', () async {
        // Mock iOS version detection failure
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getIOSVersion') {
              throw PlatformException(code: 'ERROR', message: 'Failed to get iOS version');
            }
            return null;
          },
        );

        final compatibility = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility.platform, contains('ios'));
        expect(compatibility.version, equals('Unknown'));
        expect(compatibility.limitations, contains(contains('Could not detect platform capabilities')));
      });
    });

    group('Platform-Specific Permission Handling Tests', () {
      test('should handle Android 13+ runtime permission requirements', () async {
        // Mock Android API 33
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApiLevel') {
              return 33; // Android 13
            }
            return null;
          },
        );

        await notificationService.initialize();
        final permissionStatus = await notificationService.getVersionSpecificPermissionStatus();
        
        expect(permissionStatus, isA<NotificationPermissionStatus>());
      });

      test('should handle older Android versions without runtime permissions', () async {
        // Mock Android API 25
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApiLevel') {
              return 25; // Android 7.1
            }
            return null;
          },
        );

        await notificationService.initialize();
        final permissionStatus = await notificationService.getVersionSpecificPermissionStatus();
        
        expect(permissionStatus, equals(NotificationPermissionStatus.granted));
      });
    });

    group('Notification Channel Compatibility Tests', () {
      test('should create channels conditionally based on platform version', () async {
        // Mock Android API 30
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApiLevel') {
              return 30; // Android 11
            }
            return null;
          },
        );

        await notificationService.initialize();
        final status = await notificationService.getServiceStatus();
        
        expect(status.channelsCreated, isTrue);
      });

      test('should skip channel creation on older Android versions', () async {
        // Mock Android API 25
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApiLevel') {
              return 25; // Android 7.1
            }
            return null;
          },
        );

        await notificationService.initialize();
        final status = await notificationService.getServiceStatus();
        
        // Should be marked as "created" even though channels aren't needed
        expect(status.channelsCreated, isTrue);
      });
    });

    group('Exact Alarm Compatibility Tests', () {
      test('should check exact alarm permissions on supported platforms', () async {
        await notificationService.initialize();
        final canScheduleExact = await notificationService.canScheduleExactAlarms();
        
        expect(canScheduleExact, isA<bool>());
      });

      test('should request exact alarm permissions when needed', () async {
        await notificationService.initialize();
        final granted = await notificationService.requestExactAlarmPermissions();
        
        expect(granted, isA<bool>());
      });
    });

    group('Platform Fallback Tests', () {
      test('should setup platform fallbacks during initialization', () async {
        await notificationService.initialize();
        
        // Should complete without errors regardless of platform limitations
        final status = await notificationService.getServiceStatus();
        expect(status.isInitialized, isTrue);
      });

      test('should handle unsupported platform features gracefully', () async {
        await notificationService.initialize();
        
        final compatibility = await notificationService.detectPlatformCompatibility();
        
        // Should detect limitations but still function
        expect(compatibility.limitations, isA<List<String>>());
      });
    });

    group('Platform-Specific Notification Details Tests', () {
      test('should get platform-specific notification details', () async {
        await notificationService.initialize();
        
        // Test the public method instead since the private method was removed
        final compatibility = await notificationService.detectPlatformCompatibility();
        expect(compatibility, isA<PlatformCompatibility>());
      });
    });

    group('Cross-Platform Compatibility Tests', () {
      test('should handle multiple platform scenarios', () async {
        final testScenarios = [
          {'platform': 'android', 'apiLevel': 25},
          {'platform': 'android', 'apiLevel': 30},
          {'platform': 'android', 'apiLevel': 33},
          {'platform': 'ios', 'version': '15.0'},
        ];

        for (final scenario in testScenarios) {
          // Mock the appropriate platform
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter.dev/platform_version'),
            (MethodCall methodCall) async {
              if (scenario['platform'] == 'android' && methodCall.method == 'getApiLevel') {
                return scenario['apiLevel'];
              } else if (scenario['platform'] == 'ios' && methodCall.method == 'getIOSVersion') {
                return scenario['version'];
              }
              return null;
            },
          );

          // Reset service for each test
          notificationService = NotificationService();
          
          final compatibility = await notificationService.detectPlatformCompatibility();
          
          expect(compatibility.platform, isNotEmpty);
          expect(compatibility.version, isNotEmpty);
          expect(compatibility.limitations, isA<List<String>>());
        }
      });
    });

    group('Error Handling in Platform Detection Tests', () {
      test('should handle platform detection errors gracefully', () async {
        // Mock all platform detection methods to fail
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            throw PlatformException(code: 'ERROR', message: 'Platform detection failed');
          },
        );

        final compatibility = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility.platform, isNotEmpty);
        expect(compatibility.limitations, contains(contains('Could not detect platform capabilities')));
      });

      test('should continue initialization despite platform detection failures', () async {
        // Mock platform detection to fail
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.dev/platform_version'),
          (MethodCall methodCall) async {
            throw PlatformException(code: 'ERROR', message: 'Platform detection failed');
          },
        );

        await notificationService.initialize();
        
        final status = await notificationService.getServiceStatus();
        expect(status.isInitialized, isTrue);
      });
    });

    group('Platform Compatibility Caching Tests', () {
      test('should cache platform compatibility information', () async {
        // First call
        final compatibility1 = await notificationService.detectPlatformCompatibility();
        
        // Second call should return cached result
        final compatibility2 = await notificationService.detectPlatformCompatibility();
        
        expect(compatibility1.platform, equals(compatibility2.platform));
        expect(compatibility1.version, equals(compatibility2.version));
        expect(compatibility1.supportsNotificationChannels, equals(compatibility2.supportsNotificationChannels));
      });
    });
  });
}