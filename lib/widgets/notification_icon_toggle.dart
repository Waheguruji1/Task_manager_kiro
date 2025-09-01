import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'custom_time_picker_modal.dart';

/// Icon toggle for notification settings with modal integration
class NotificationIconToggle extends StatelessWidget {
  final DateTime? notificationTime;
  final Function(DateTime?) onNotificationChanged;
  final bool enabled;

  const NotificationIconToggle({
    super.key,
    this.notificationTime,
    required this.onNotificationChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasNotification = notificationTime != null;
    final isActive = enabled;

    return Tooltip(
      message: hasNotification 
          ? 'Notification set for ${_formatTime(notificationTime!)}'
          : 'Set notification time',
      child: GestureDetector(
        onTap: isActive ? () => _showNotificationModal(context) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: hasNotification 
                ? AppTheme.greyPrimary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: hasNotification 
                ? Border.all(color: AppTheme.greyPrimary.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: hasNotification ? 1.1 : 1.0,
            child: Icon(
              hasNotification 
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              size: 20,
              color: hasNotification 
                  ? AppTheme.greyPrimary
                  : (isActive 
                      ? AppTheme.secondaryText.withValues(alpha: 0.6)
                      : AppTheme.secondaryText.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationModal(BuildContext context) {
    showCustomTimePickerModal(
      context,
      initialTime: notificationTime,
      onTimeSelected: onNotificationChanged,
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}