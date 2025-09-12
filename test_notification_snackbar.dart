import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/providers/providers.dart';
import 'lib/widgets/notification_debug_snackbar.dart';

/// Test file to demonstrate the notification snackbar system
/// 
/// This file shows how the NotificationService now uses snackbars
/// instead of debugPrint statements for user-visible debugging
void main() {
  runApp(const ProviderScope(child: NotificationSnackbarTestApp()));
}

class NotificationSnackbarTestApp extends StatelessWidget {
  const NotificationSnackbarTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Snackbar Test',
      theme: ThemeData.dark(),
      home: const NotificationSnackbarTestScreen(),
    );
  }
}

class NotificationSnackbarTestScreen extends ConsumerStatefulWidget {
  const NotificationSnackbarTestScreen({super.key});

  @override
  ConsumerState<NotificationSnackbarTestScreen> createState() => _NotificationSnackbarTestScreenState();
}

class _NotificationSnackbarTestScreenState extends ConsumerState<NotificationSnackbarTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Snackbar Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Notification Snackbar System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'The NotificationService now shows user-friendly snackbar messages instead of debugPrint statements. Test the different snackbar types below:',
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _testSuccessSnackbar(),
              child: const Text('Test Success Snackbar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _testErrorSnackbar(),
              child: const Text('Test Error Snackbar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _testWarningSnackbar(),
              child: const Text('Test Warning Snackbar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _testInfoSnackbar(),
              child: const Text('Test Info Snackbar'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _testNotificationService(),
              child: const Text('Test Notification Service with Snackbars'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _testPermissionError(),
              child: const Text('Test Permission Error with Action'),
            ),
          ],
        ),
      ),
    );
  }

  void _testSuccessSnackbar() {
    NotificationDebugSnackbar.showSuccess(
      context,
      'Notification scheduled successfully!',
    );
  }

  void _testErrorSnackbar() {
    NotificationDebugSnackbar.showError(
      context,
      'Failed to schedule notification due to permissions',
    );
  }

  void _testWarningSnackbar() {
    NotificationDebugSnackbar.showWarning(
      context,
      'Using approximate timing (exact alarms not available)',
    );
  }

  void _testInfoSnackbar() {
    NotificationDebugSnackbar.showInfo(
      context,
      'Initializing notification service...',
    );
  }

  void _testNotificationService() async {
    final notificationService = ref.read(notificationServiceProvider);
    
    // Set context for snackbar messages
    notificationService.setContext(context);
    
    // Test initialization with snackbar feedback
    try {
      await notificationService.initialize(context: context);
      NotificationDebugSnackbar.showSuccess(
        context,
        'Notification service initialized with snackbar support!',
      );
    } catch (e) {
      NotificationDebugSnackbar.showError(
        context,
        'Failed to initialize notification service: $e',
      );
    }
  }

  void _testPermissionError() {
    NotificationDebugSnackbar.showPermissionError(
      context,
      'Notification permissions are required to set reminders',
      () {
        // This would normally open settings
        NotificationDebugSnackbar.showInfo(
          context,
          'Opening notification settings...',
        );
      },
    );
  }
}