import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/services/permission_service.dart';
import 'lib/services/notification_service.dart';
import 'lib/providers/providers.dart';

/// Simple test script to verify permission service functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Testing Permission Service...');
  
  try {
    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Check permission status
    final status = await notificationService.checkAllPermissions();
    print('Permission Status: $status');
    
    // Get status message
    final message = await notificationService.getPermissionStatusMessage();
    print('Status Message: $message');
    
    // Get comprehensive status
    final comprehensive = await notificationService.getComprehensivePermissionStatus();
    print('Comprehensive Status: $comprehensive');
    
    print('Permission service test completed successfully!');
  } catch (e, stackTrace) {
    print('Error testing permission service: $e');
    print('Stack trace: $stackTrace');
  }
}