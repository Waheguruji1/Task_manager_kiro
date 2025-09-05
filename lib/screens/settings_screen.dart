import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/responsive.dart';
import '../utils/routes.dart';
import '../providers/providers.dart';
import '../services/share_service.dart';
import '../widgets/permission_status_widget.dart';

/// Settings Screen Widget
///
/// Provides app settings and user preferences management
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;
  bool _isUpdatingNotifications = false;
  bool _isSendingTestNotification = false;
  bool _isCheckingServiceStatus = false;
  bool _isUpdatingAutoDelete = false;

  /// Handle clear all data
  Future<void> _handleClearAllData() async {
    final confirmed = await _showClearDataConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefsService =
          await ref.read(asyncPreferencesServiceProvider.future);
      final dbService = await ref.read(asyncDatabaseServiceProvider.future);

      // Clear all tasks efficiently
      await dbService.deleteAllTasks();

      // Clear user preferences
      await prefsService.clearUserData();

      // Invalidate all providers to clear cached data
      ref.invalidate(asyncTaskStateNotifierProvider);
      ref.invalidate(allTasksProvider);
      ref.invalidate(asyncUserStateNotifierProvider);
      ref.invalidate(asyncPreferencesServiceProvider);
      ref.invalidate(asyncDatabaseServiceProvider);
      ref.invalidate(completionHeatmapDataProvider);
      ref.invalidate(taskChangeNotifierProvider);

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
            context, 'All data cleared successfully');
        // Navigate back to welcome screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.welcome,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Failed to clear data: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show clear data confirmation dialog
  Future<bool> _showClearDataConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        ),
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: AppTheme.primaryText),
        ),
        content: const Text(
          'This will permanently delete all your tasks and reset the app. This action cannot be undone.',
          style: TextStyle(color: AppTheme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Handle share app
  Future<void> _handleShareApp() async {
    try {
      final success = await ShareService.shareApp();
      if (!success && mounted) {
        ErrorHandler.showErrorSnackBar(context, 'Failed to share app');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, 'Failed to share app');
      }
    }
  }

  /// Handle notification toggle
  Future<void> _handleNotificationToggle(bool enabled) async {
    if (_isUpdatingNotifications) return;

    setState(() {
      _isUpdatingNotifications = true;
    });

    try {
      final prefsService =
          await ref.read(asyncPreferencesServiceProvider.future);
      final notificationService = ref.read(notificationServiceProvider);

      if (enabled) {
        // Request all permissions with comprehensive flow
        if (!mounted) return;
        final result = await notificationService.requestAllPermissions(
          context: context,
          showDialogs: true,
        );
        
        if (!result.success && !result.partialSuccess) {
          if (mounted) {
            ErrorHandler.showErrorSnackBar(
              context,
              result.message,
            );
            
            // Show settings dialog if manual action is needed
            if (result.needsManualAction && mounted) {
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                await notificationService.showPermissionSettingsDialog(context);
              }
            }
          }
          return;
        }
        
        // Show warning if only partial success (basic notifications but no exact alarms)
        if (result.partialSuccess && mounted) {
          ErrorHandler.showWarningSnackBar(
            context,
            result.message,
          );
        }

        // Enable notifications and reschedule all
        await prefsService.setNotificationsEnabled(true);
        final allTasks = await ref.read(allTasksProvider.future);
        await notificationService.rescheduleAllNotifications(allTasks);
      } else {
        // Disable notifications and cancel all
        await prefsService.setNotificationsEnabled(false);
        await notificationService.cancelAllNotifications();
      }

      // Refresh providers
      ref.invalidate(notificationsEnabledProvider);
      ref.invalidate(notificationPermissionStatusProvider);

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          AppStrings.notificationSettingsUpdated,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Failed to update notification settings: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingNotifications = false;
        });
      }
    }
  }

  /// Handle request notification permission with comprehensive flow
  Future<void> _handleRequestPermission() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      
      // Use the new comprehensive permission request
      final result = await notificationService.requestAllPermissions(
        context: context,
        showDialogs: true,
      );

      // Refresh permission status
      ref.invalidate(notificationPermissionStatusProvider);

      if (mounted) {
        if (result.success) {
          ErrorHandler.showSuccessSnackBar(
            context,
            result.message,
          );
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            result.message,
          );
          
          // If manual action is needed, show settings dialog
          if (result.needsManualAction && mounted) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              await notificationService.showPermissionSettingsDialog(context);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Failed to request notification permission',
        );
      }
    }
  }

  /// Show detailed permission information dialog
  Future<void> _showDetailedPermissionInfo() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Details'),
          content: const SizedBox(
            width: double.maxFinite,
            child: DetailedPermissionStatusWidget(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleRequestPermission();
              },
              child: const Text('Fix Permissions'),
            ),
          ],
        );
      },
    );
  }

  /// Handle send test notification
  Future<void> _handleSendTestNotification() async {
    if (_isSendingTestNotification) return;

    setState(() {
      _isSendingTestNotification = true;
    });

    try {
      final notificationService = ref.read(notificationServiceProvider);
      final success = await notificationService.sendTestNotification();

      if (mounted) {
        if (success) {
          ErrorHandler.showSuccessSnackBar(
            context,
            'Test notification sent successfully! Check your notification panel.',
          );
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            'Failed to send test notification. Check your notification settings.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Failed to send test notification: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingTestNotification = false;
        });
      }
    }
  }

  /// Handle send scheduled test notification
  Future<void> _handleSendScheduledTestNotification() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final notificationId = await notificationService
          .sendScheduledTestNotification(delayMinutes: 1);

      if (mounted) {
        if (notificationId != null) {
          ErrorHandler.showSuccessSnackBar(
            context,
            'Scheduled test notification will appear in 1 minute (ID: $notificationId)',
          );
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            'Failed to schedule test notification. Check your notification settings.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Failed to schedule test notification: ${e.toString()}',
        );
      }
    }
  }

  /// Handle auto-delete toggle
  Future<void> _handleAutoDeleteToggle(bool enabled) async {
    if (_isUpdatingAutoDelete) return;

    setState(() {
      _isUpdatingAutoDelete = true;
    });

    try {
      final prefsService =
          await ref.read(asyncPreferencesServiceProvider.future);

      // Update the setting
      await prefsService.setAutoDeleteEnabled(enabled);

      // If auto-delete is being enabled after being disabled, perform immediate cleanup
      if (enabled) {
        final cleanupService = ref.read(taskCleanupServiceProvider);
        final dbService = await ref.read(asyncDatabaseServiceProvider.future);

        // Perform immediate cleanup of tasks older than 3 months
        final cleanupSuccess =
            await cleanupService.performImmediateCleanup(dbService);

        if (cleanupSuccess) {
          // Refresh task providers to reflect cleanup
          ref.invalidate(allTasksProvider);
          ref.invalidate(taskChangeNotifierProvider);

          if (mounted) {
            ErrorHandler.showSuccessSnackBar(
              context,
              'Auto-delete enabled. Old completed tasks have been cleaned up.',
            );
          }
        } else {
          if (mounted) {
            ErrorHandler.showSuccessSnackBar(
              context,
              'Auto-delete enabled, but cleanup encountered some issues.',
            );
          }
        }
      } else {
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(
            context,
            'Auto-delete disabled. Your completed tasks will be preserved.',
          );
        }
      }

      // Refresh the provider
      ref.invalidate(autoDeleteEnabledProvider);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Failed to update auto-delete setting: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAutoDelete = false;
        });
      }
    }
  }

  /// Show notification service status dialog
  Future<void> _showServiceStatusDialog() async {
    if (_isCheckingServiceStatus) return;

    setState(() {
      _isCheckingServiceStatus = true;
    });

    try {
      final notificationService = ref.read(notificationServiceProvider);
      final serviceStatus = await notificationService.getServiceStatus();
      final platformCompatibility =
          await notificationService.detectPlatformCompatibility();
      final pendingNotifications =
          await notificationService.getDetailedPendingNotifications();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceGrey,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppTheme.containerBorderRadius),
            ),
            title: Row(
              children: [
                Icon(
                  serviceStatus.isHealthy ? Icons.check_circle : Icons.warning,
                  color: serviceStatus.isHealthy ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingS),
                const Text(
                  'Notification Service Status',
                  style: TextStyle(color: AppTheme.primaryText, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Service Health
                  _buildStatusItem('Service Health',
                      serviceStatus.isHealthy ? 'Healthy' : 'Unhealthy'),
                  _buildStatusItem('Initialized',
                      serviceStatus.isInitialized ? 'Yes' : 'No'),
                  _buildStatusItem('Channels Created',
                      serviceStatus.channelsCreated ? 'Yes' : 'No'),
                  _buildStatusItem('Timezone Ready',
                      serviceStatus.timezoneInitialized ? 'Yes' : 'No'),
                  _buildStatusItem('Permissions Granted',
                      serviceStatus.permissionsGranted ? 'Yes' : 'No'),

                  const SizedBox(height: AppTheme.spacingM),

                  // Platform Info
                  Text(
                    'Platform Information',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  _buildStatusItem('Platform',
                      '${platformCompatibility.platform} ${platformCompatibility.version}'),
                  _buildStatusItem(
                      'Supports Channels',
                      platformCompatibility.supportsNotificationChannels
                          ? 'Yes'
                          : 'No'),
                  _buildStatusItem('Supports Exact Alarms',
                      platformCompatibility.supportsExactAlarms ? 'Yes' : 'No'),

                  const SizedBox(height: AppTheme.spacingM),

                  // Pending Notifications
                  Text(
                    'Pending Notifications',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  _buildStatusItem('Count', '${pendingNotifications.length}'),

                  // Errors and Warnings
                  if (serviceStatus.errors.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Errors',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    ...serviceStatus.errors.map((error) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $error',
                            style: AppTheme.caption.copyWith(color: Colors.red),
                          ),
                        )),
                  ],

                  if (serviceStatus.warnings.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Warnings',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    ...serviceStatus.warnings.map((warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $warning',
                            style:
                                AppTheme.caption.copyWith(color: Colors.orange),
                          ),
                        )),
                  ],

                  // Platform Limitations
                  if (platformCompatibility.limitations.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Platform Limitations',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    ...platformCompatibility.limitations
                        .map((limitation) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $limitation',
                                style: AppTheme.caption
                                    .copyWith(color: AppTheme.secondaryText),
                              ),
                            )),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppTheme.greyPrimary),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Failed to get service status: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingServiceStatus = false;
        });
      }
    }
  }

  /// Build status item for dialog
  Widget _buildStatusItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show notification troubleshooting dialog
  Future<void> _showTroubleshootingDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        ),
        title: const Text(
          'Notification Troubleshooting',
          style: TextStyle(color: AppTheme.primaryText),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTroubleshootingItem(
                'Notifications not appearing',
                [
                  'Check notification permissions in device settings',
                  'Ensure notifications are enabled in the app',
                  'Check if Do Not Disturb mode is enabled',
                  'Try sending a test notification',
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildTroubleshootingItem(
                'Notifications appearing late',
                [
                  'Check battery optimization settings',
                  'Add the app to battery optimization whitelist',
                  'Ensure exact alarm permissions are granted (Android 12+)',
                  'Check if power saving mode is enabled',
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              _buildTroubleshootingItem(
                'Test notification failed',
                [
                  'Check service status for errors',
                  'Restart the app and try again',
                  'Check device notification settings',
                  'Ensure the app has all required permissions',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.greyPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Build troubleshooting item
  Widget _buildTroubleshootingItem(String title, List<String> solutions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        ...solutions.map((solution) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $solution',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryText,
                ),
              ),
            )),
      ],
    );
  }

  /// Build settings section
  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingS,
            AppTheme.spacingL,
            AppTheme.spacingS,
            AppTheme.spacingS,
          ),
          child: Text(
            title,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.greyPrimary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGrey,
            borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// Build settings item
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    bool showDivider = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.greyPrimary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.greyPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyLarge.copyWith(
                        color: textColor ?? AppTheme.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build notification toggle item
  Widget _buildNotificationToggleItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.greyPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.greyPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
              ),
            )
          else
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.greyPrimary,
              inactiveThumbColor: AppTheme.secondaryText,
              inactiveTrackColor: AppTheme.greyLight.withValues(alpha: 0.2),
              activeTrackColor: AppTheme.greyPrimary.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }

  /// Build permission status item
  Widget _buildPermissionStatusItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool hasPermission,
    VoidCallback? onRequestPermission,
    bool showDetailButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: (hasPermission ? Colors.green : Colors.orange)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: hasPermission ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!hasPermission && onRequestPermission != null)
                TextButton(
                  onPressed: onRequestPermission,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.greyPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                  ),
                  child: const Text(AppStrings.requestPermissionButton),
                ),
              if (showDetailButton)
                TextButton(
                  onPressed: _showDetailedPermissionInfo,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.greyPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                  ),
                  child: const Text('Details'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNameAsync = ref.watch(userNameProvider);
    final responsivePadding = ResponsiveUtils.getOptimalMobilePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsivePadding.horizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: AppTheme.headingLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      userNameAsync.when(
                        data: (userName) => Text(
                          'Welcome, ${userName ?? 'User'}!',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        loading: () => Text(
                          'Welcome, User!',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Welcome, User!',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // App Settings
                _buildSettingsSection(
                  title: 'App',
                  children: [
                    _buildSettingsItem(
                      icon: Icons.share,
                      title: 'Share App',
                      subtitle: 'Tell your friends about this app',
                      onTap: _handleShareApp,
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'Version ${AppConstants.appVersion}',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: AppConstants.appVersion,
                          applicationLegalese: '© 2025 Task Manager Team',
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                'A simple and elegant task management app to help you stay organized and productive.',
                                style: TextStyle(color: AppTheme.secondaryText),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                // Notification Settings
                _buildSettingsSection(
                  title: AppStrings.notificationsTitle,
                  children: [
                    // Notification toggle
                    Consumer(
                      builder: (context, ref, child) {
                        final notificationsEnabledAsync =
                            ref.watch(notificationsEnabledProvider);

                        return notificationsEnabledAsync.when(
                          data: (isEnabled) => _buildNotificationToggleItem(
                            icon: Icons.notifications,
                            title: AppStrings.enableNotificationsTitle,
                            subtitle: AppStrings.enableNotificationsSubtitle,
                            value: isEnabled,
                            onChanged: _handleNotificationToggle,
                            isLoading: _isUpdatingNotifications,
                          ),
                          loading: () => _buildNotificationToggleItem(
                            icon: Icons.notifications,
                            title: AppStrings.enableNotificationsTitle,
                            subtitle: AppStrings.enableNotificationsSubtitle,
                            value: false,
                            onChanged: (_) {},
                            isLoading: true,
                          ),
                          error: (_, __) => _buildNotificationToggleItem(
                            icon: Icons.notifications,
                            title: AppStrings.enableNotificationsTitle,
                            subtitle: AppStrings.enableNotificationsSubtitle,
                            value: false,
                            onChanged: _handleNotificationToggle,
                          ),
                        );
                      },
                    ),

                    // Permission Status Widget
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                      child: PermissionStatusWidget(),
                    ),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM),
                      color: AppTheme.borderWhite.withValues(alpha: 0.3),
                    ),

                    // Permission status
                    Consumer(
                      builder: (context, ref, child) {
                        final permissionStatusAsync =
                            ref.watch(notificationPermissionStatusProvider);

                        return permissionStatusAsync.when(
                          data: (hasPermission) => _buildPermissionStatusItem(
                            icon: hasPermission
                                ? Icons.check_circle
                                : Icons.warning,
                            title: AppStrings.notificationPermissionTitle,
                            subtitle: hasPermission
                                ? AppStrings.notificationPermissionGranted
                                : AppStrings.notificationPermissionDenied,
                            hasPermission: hasPermission,
                            onRequestPermission:
                                hasPermission ? null : _handleRequestPermission,
                            showDetailButton: true,
                          ),
                          loading: () => _buildPermissionStatusItem(
                            icon: Icons.info,
                            title: AppStrings.notificationPermissionTitle,
                            subtitle: 'Checking permission status...',
                            hasPermission: false,
                          ),
                          error: (_, __) => _buildPermissionStatusItem(
                            icon: Icons.error,
                            title: AppStrings.notificationPermissionTitle,
                            subtitle: 'Unable to check permission status',
                            hasPermission: false,
                          ),
                        );
                      },
                    ),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM),
                      color: AppTheme.borderWhite.withValues(alpha: 0.3),
                    ),

                    // Test notification button
                    _buildSettingsItem(
                      icon: Icons.notification_add,
                      title: 'Send Test Notification',
                      subtitle: 'Test if notifications are working correctly',
                      onTap: _isSendingTestNotification
                          ? () {}
                          : _handleSendTestNotification,
                    ),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM),
                      color: AppTheme.borderWhite.withValues(alpha: 0.3),
                    ),

                    // Scheduled test notification button
                    _buildSettingsItem(
                      icon: Icons.schedule,
                      title: 'Send Scheduled Test',
                      subtitle: 'Test scheduled notification (1 minute delay)',
                      onTap: _handleSendScheduledTestNotification,
                    ),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM),
                      color: AppTheme.borderWhite.withValues(alpha: 0.3),
                    ),

                    // Service status button
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: 'Service Status',
                      subtitle:
                          'View detailed notification service information',
                      onTap: _isCheckingServiceStatus
                          ? () {}
                          : _showServiceStatusDialog,
                    ),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM),
                      color: AppTheme.borderWhite.withValues(alpha: 0.3),
                    ),

                    // Troubleshooting button
                    _buildSettingsItem(
                      icon: Icons.help_outline,
                      title: 'Troubleshooting',
                      subtitle: 'Get help with notification issues',
                      onTap: _showTroubleshootingDialog,
                      showDivider: false,
                    ),
                  ],
                ),

                // Data Management
                _buildSettingsSection(
                  title: 'Data',
                  children: [
                    // Auto-delete toggle
                    Consumer(
                      builder: (context, ref, child) {
                        final autoDeleteAsync =
                            ref.watch(autoDeleteEnabledProvider);

                        return autoDeleteAsync.when(
                          data: (isEnabled) => _buildNotificationToggleItem(
                            icon: Icons.auto_delete,
                            title: 'Auto-Delete Old Tasks',
                            subtitle:
                                'Automatically delete completed tasks older than 2 months',
                            value: isEnabled,
                            onChanged: _handleAutoDeleteToggle,
                            isLoading: _isUpdatingAutoDelete,
                          ),
                          loading: () => _buildNotificationToggleItem(
                            icon: Icons.auto_delete,
                            title: 'Auto-Delete Old Tasks',
                            subtitle:
                                'Automatically delete completed tasks older than 2 months',
                            value: true,
                            onChanged: (_) {},
                            isLoading: true,
                          ),
                          error: (_, __) => _buildNotificationToggleItem(
                            icon: Icons.auto_delete,
                            title: 'Auto-Delete Old Tasks',
                            subtitle:
                                'Automatically delete completed tasks older than 2 months',
                            value: true,
                            onChanged: _handleAutoDeleteToggle,
                            isLoading: false,
                          ),
                        );
                      },
                    ),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM),
                      color: AppTheme.borderWhite.withValues(alpha: 0.1),
                    ),

                    _buildSettingsItem(
                      icon: Icons.delete_forever,
                      title: 'Clear All Data',
                      subtitle: 'Delete all tasks and reset the app',
                      onTap: _isLoading ? () {} : _handleClearAllData,
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      showDivider: false,
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
