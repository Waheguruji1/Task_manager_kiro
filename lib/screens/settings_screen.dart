import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/responsive.dart';
import '../providers/providers.dart';
import '../services/share_service.dart';

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

  /// Handle clear all data
  Future<void> _handleClearAllData() async {
    final confirmed = await _showClearDataConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefsService = await ref.read(asyncPreferencesServiceProvider.future);
      final dbService = await ref.read(asyncDatabaseServiceProvider.future);
      
      // Clear all tasks
      final allTasks = await dbService.getAllTasks();
      for (final task in allTasks) {
        if (task.id != null) {
          await dbService.deleteTask(task.id!);
        }
      }
      
      // Clear user preferences
      await prefsService.clearUserData();
      
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'All data cleared successfully');
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
      final prefsService = await ref.read(asyncPreferencesServiceProvider.future);
      final notificationService = ref.read(notificationServiceProvider);
      
      if (enabled) {
        // Request permission first
        final hasPermission = await notificationService.requestPermissions();
        if (!hasPermission) {
          if (mounted) {
            ErrorHandler.showErrorSnackBar(
              context, 
              'Notification permission denied. Please enable in device settings.',
            );
          }
          return;
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

  /// Handle request notification permission
  Future<void> _handleRequestPermission() async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final hasPermission = await notificationService.requestPermissions();
      
      // Refresh permission status
      ref.invalidate(notificationPermissionStatusProvider);
      
      if (mounted) {
        if (hasPermission) {
          ErrorHandler.showSuccessSnackBar(
            context,
            'Notification permission granted!',
          );
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            'Notification permission denied. Please enable in device settings.',
          );
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
            AppTheme.spacingM,
            AppTheme.spacingL,
            AppTheme.spacingM,
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
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.surfaceGrey,
            borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
            border: Border.all(color: AppTheme.borderWhite),
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
                  color: (iconColor ?? AppTheme.greyPrimary).withValues(alpha: 0.1),
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.greyPrimary,
              inactiveThumbColor: AppTheme.secondaryText,
              inactiveTrackColor: AppTheme.secondaryText.withValues(alpha: 0.3),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: (hasPermission ? Colors.green : Colors.orange).withValues(alpha: 0.1),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNameAsync = ref.watch(userNameProvider);
    final responsivePadding = ResponsiveUtils.getScreenPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsivePadding.horizontal / 2,
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
                        final notificationsEnabledAsync = ref.watch(notificationsEnabledProvider);
                        
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
                    
                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                      color: AppTheme.borderWhite.withValues(alpha: 0.3),
                    ),
                    
                    // Permission status
                    Consumer(
                      builder: (context, ref, child) {
                        final permissionStatusAsync = ref.watch(notificationPermissionStatusProvider);
                        
                        return permissionStatusAsync.when(
                          data: (hasPermission) => _buildPermissionStatusItem(
                            icon: hasPermission ? Icons.check_circle : Icons.warning,
                            title: AppStrings.notificationPermissionTitle,
                            subtitle: hasPermission 
                              ? AppStrings.notificationPermissionGranted
                              : AppStrings.notificationPermissionDenied,
                            hasPermission: hasPermission,
                            onRequestPermission: hasPermission ? null : _handleRequestPermission,
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
                  ],
                ),

                // Data Management
                _buildSettingsSection(
                  title: 'Data',
                  children: [
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