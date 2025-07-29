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