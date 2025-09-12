import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/permission_service.dart';
import '../providers/providers.dart';

/// Widget to display comprehensive notification permission status
class PermissionStatusWidget extends ConsumerWidget {
  const PermissionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<PermissionStatus>(
      future: ref.read(notificationServiceProvider).checkAllPermissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Checking permissions...'),
                ],
              ),
            ),
          );
        }

        final status = snapshot.data ?? PermissionStatus.error;
        return _buildStatusCard(context, status);
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, PermissionStatus status) {
    final theme = Theme.of(context);
    
    Color cardColor;
    Color iconColor;
    IconData icon;
    String title;
    String subtitle;
    
    switch (status) {
      case PermissionStatus.allGranted:
        cardColor = Colors.green.withValues(alpha: 0.1);
        iconColor = Colors.green;
        icon = Icons.check_circle;
        title = 'All Permissions Granted';
        subtitle = 'Notifications will work perfectly';
        break;
      case PermissionStatus.basicNotificationsDenied:
        cardColor = Colors.red.withValues(alpha: 0.1);
        iconColor = Colors.red;
        icon = Icons.error;
        title = 'Notifications Disabled';
        subtitle = 'Enable notifications to receive task reminders';
        break;
      case PermissionStatus.exactAlarmsDenied:
        cardColor = Colors.orange.withValues(alpha: 0.1);
        iconColor = Colors.orange;
        icon = Icons.warning;
        title = 'Limited Precision';
        subtitle = 'Enable exact alarms for precise timing';
        break;
      case PermissionStatus.notInitialized:
        cardColor = Colors.grey.withValues(alpha: 0.1);
        iconColor = Colors.grey;
        icon = Icons.info;
        title = 'Not Initialized';
        subtitle = 'Permission service is starting up';
        break;
      case PermissionStatus.error:
        cardColor = Colors.red.withValues(alpha: 0.1);
        iconColor = Colors.red;
        icon = Icons.error_outline;
        title = 'Permission Error';
        subtitle = 'Unable to check permission status';
        break;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to show detailed permission breakdown
class DetailedPermissionStatusWidget extends ConsumerWidget {
  const DetailedPermissionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.read(notificationServiceProvider);
    notificationService.setContext(context);
    
    return FutureBuilder<Map<String, dynamic>>(
      future: notificationService.getComprehensivePermissionStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final status = snapshot.data ?? {};
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permission Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPermissionRow(
                  'Basic Notifications',
                  status['basicNotifications'] ?? false,
                ),
                const SizedBox(height: 8),
                _buildPermissionRow(
                  'Exact Alarms',
                  status['exactAlarms'] ?? false,
                ),
                const SizedBox(height: 12),
                Text(
                  'Platform: ${status['platform'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  status['recommendedAction'] ?? 'No recommendations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionRow(String label, bool granted) {
    return Row(
      children: [
        Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          granted ? 'Granted' : 'Denied',
          style: TextStyle(
            color: granted ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}