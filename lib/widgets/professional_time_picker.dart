import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class ProfessionalTimePicker extends StatefulWidget {
  final TimeOfDay? initialTime;
  final Function(TimeOfDay?) onTimeChanged;
  final bool enabled;

  const ProfessionalTimePicker({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
    this.enabled = true,
  });

  @override
  State<ProfessionalTimePicker> createState() => _ProfessionalTimePickerState();
}

class _ProfessionalTimePickerState extends State<ProfessionalTimePicker> with TickerProviderStateMixin {
  TimeOfDay? _selectedTime;
  bool _hasNotification = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _hasNotification = widget.initialTime != null;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleNotification() {
    if (!widget.enabled) return;
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _hasNotification = !_hasNotification;
      if (!_hasNotification) {
        _selectedTime = null;
        widget.onTimeChanged(null);
      } else {
        // Set default time to current time + 1 hour
        final now = TimeOfDay.now();
        _selectedTime = TimeOfDay(
          hour: (now.hour + 1) % 24,
          minute: now.minute,
        );
        widget.onTimeChanged(_selectedTime);
      }
    });
  }

  Future<void> _selectTime() async {
    if (!widget.enabled || !_hasNotification) return;

    HapticFeedback.selectionClick();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Select reminder time',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.surfaceGrey,
              hourMinuteTextColor: AppTheme.primaryText,
              hourMinuteColor: AppTheme.backgroundDark,
              dialHandColor: AppTheme.greyPrimary,
              dialBackgroundColor: AppTheme.backgroundDark,
              dialTextColor: AppTheme.primaryText,
              entryModeIconColor: AppTheme.greyPrimary,
              helpTextStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryText,
              ),
              hourMinuteTextStyle: AppTheme.headingLarge.copyWith(
                color: AppTheme.primaryText,
              ),
            ),
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.greyPrimary,
              onPrimary: AppTheme.primaryText,
              surface: AppTheme.surfaceGrey,
              onSurface: AppTheme.primaryText,
              outline: AppTheme.greyPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      widget.onTimeChanged(picked);
      
      // Show confirmation feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder set for ${_formatTime(picked)}',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryText),
            ),
            backgroundColor: AppTheme.greyPrimary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: Border.all(
          color: _hasNotification 
              ? AppTheme.greyPrimary.withValues(alpha: 0.4)
              : AppTheme.greyPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _hasNotification 
                      ? Icons.notifications_active
                      : Icons.notifications_outlined,
                  color: _hasNotification 
                      ? AppTheme.greyPrimary 
                      : AppTheme.secondaryText,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  'Reminder Notification',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
              Switch(
                value: _hasNotification,
                onChanged: widget.enabled ? (_) => _toggleNotification() : null,
                activeThumbColor: AppTheme.greyPrimary,
                activeTrackColor: AppTheme.greyPrimary.withValues(alpha: 0.3),
                inactiveThumbColor: AppTheme.secondaryText,
                inactiveTrackColor: AppTheme.greyDark,
              ),
            ],
          ),
          
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _hasNotification ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingM),
                
                // Time selection button
                GestureDetector(
                  onTapDown: (_) {
                    _animationController.forward();
                  },
                  onTapUp: (_) {
                    _animationController.reverse();
                  },
                  onTapCancel: () {
                    _animationController.reverse();
                  },
                  onTap: _selectTime,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: _selectedTime != null 
                                ? AppTheme.greyPrimary.withValues(alpha: 0.1)
                                : AppTheme.backgroundDark,
                            borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                            border: Border.all(
                              color: _selectedTime != null 
                                  ? AppTheme.greyPrimary
                                  : AppTheme.greyPrimary.withValues(alpha: 0.3),
                              width: _selectedTime != null ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: _selectedTime != null 
                                    ? AppTheme.greyPrimary 
                                    : AppTheme.secondaryText,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              Expanded(
                                child: Text(
                                  _selectedTime != null 
                                      ? _formatTime(_selectedTime!)
                                      : 'Tap to select time',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: _selectedTime != null 
                                        ? AppTheme.primaryText 
                                        : AppTheme.secondaryText,
                                    fontWeight: _selectedTime != null 
                                        ? FontWeight.w600 
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                color: _selectedTime != null 
                                    ? AppTheme.greyPrimary 
                                    : AppTheme.secondaryText,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingS),
                
                // Status text
                Row(
                  children: [
                    Icon(
                      _selectedTime != null 
                          ? Icons.check_circle_outline 
                          : Icons.info_outline,
                      color: _selectedTime != null 
                          ? AppTheme.greyPrimary 
                          : AppTheme.secondaryText,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedTime != null 
                          ? 'Reminder scheduled'
                          : 'Select a time for your reminder',
                      style: AppTheme.caption.copyWith(
                        color: _selectedTime != null 
                            ? AppTheme.greyPrimary 
                            : AppTheme.secondaryText,
                        fontWeight: _selectedTime != null 
                            ? FontWeight.w500 
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}