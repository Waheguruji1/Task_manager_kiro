import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/error_handler.dart';
import '../services/share_service.dart';

/// Custom App Bar Widget
/// 
/// A themed AppBar with app name on the left and share icon on the right.
/// Follows the app's theme specifications with consistent styling and
/// integrated share functionality.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showShareButton;
  final VoidCallback? onSharePressed;
  final List<Widget>? additionalActions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showShareButton = true,
    this.onSharePressed,
    this.additionalActions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTheme.headingMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.backgroundDark,
      foregroundColor: AppTheme.primaryText,
      elevation: elevation ?? 0,
      centerTitle: false,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      
      // Actions with share icon on the right
      actions: [
        // Additional actions if provided
        if (additionalActions != null) ...additionalActions!,
        
        // Share button
        if (showShareButton)
          IconButton(
            onPressed: onSharePressed ?? _handleSharePressed,
            icon: const Icon(
              Icons.share,
              color: AppTheme.iconPrimary,
              size: 24,
            ),
            tooltip: 'Share App',
            splashRadius: 24,
          ),
        
        // Add some padding to the right
        const SizedBox(width: AppTheme.spacingS),
      ],
      
      // Icon theme for consistent styling
      iconTheme: const IconThemeData(
        color: AppTheme.iconPrimary,
        size: 24,
      ),
      
      // Action icon theme
      actionsIconTheme: const IconThemeData(
        color: AppTheme.iconPrimary,
        size: 24,
      ),
    );
  }

  /// Handle share button press
  /// Uses the ShareService to share the app
  void _handleSharePressed() async {
    try {
      final success = await ShareService.shareApp();
      if (!success) {
        ErrorHandler.logError(
          'Share operation failed',
          context: 'CustomAppBar share',
          type: ErrorType.unknown,
        );
      }
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'CustomAppBar share',
        type: ErrorType.unknown,
      );
      // Don't show error to user as sharing is not critical functionality
      // and the error might be due to user canceling the share dialog
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom App Bar with Back Button
/// 
/// A variant of CustomAppBar that includes a back button for navigation.
/// Useful for secondary screens that need navigation back to previous screen.
class CustomAppBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showShareButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSharePressed;
  final List<Widget>? additionalActions;

  const CustomAppBarWithBack({
    Key? key,
    required this.title,
    this.showShareButton = false,
    this.onBackPressed,
    this.onSharePressed,
    this.additionalActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      showShareButton: showShareButton,
      onSharePressed: onSharePressed,
      additionalActions: additionalActions,
      leading: IconButton(
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back,
          color: AppTheme.iconPrimary,
        ),
        tooltip: 'Back',
        splashRadius: 24,
      ),
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}