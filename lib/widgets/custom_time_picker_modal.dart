import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

/// Custom time picker modal with improved responsiveness and visual feedback
class CustomTimePickerModal extends StatefulWidget {
  final DateTime? initialTime;
  final Function(DateTime?) onTimeSelected;

  const CustomTimePickerModal({
    super.key,
    this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<CustomTimePickerModal> createState() => _CustomTimePickerModalState();
}

class _CustomTimePickerModalState extends State<CustomTimePickerModal>
    with TickerProviderStateMixin {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  bool _isAM = true;
  bool _isValidInput = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for button feedback
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize with current time or provided initial time
    final initialTime = widget.initialTime ?? DateTime.now();
    int hour12 = initialTime.hour;

    // Convert to 12-hour format
    if (hour12 == 0) {
      hour12 = 12;
      _isAM = true;
    } else if (hour12 > 12) {
      hour12 = hour12 - 12;
      _isAM = false;
    } else if (hour12 == 12) {
      _isAM = false;
    } else {
      _isAM = true;
    }

    _hourController = TextEditingController(text: hour12.toString());
    _minuteController = TextEditingController(
        text: initialTime.minute.toString().padLeft(2, '0'));

    // Add listeners to validate input in real-time
    _hourController.addListener(_validateInput);
    _minuteController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final hourText = _hourController.text;
    final minuteText = _minuteController.text;

    bool isValid = true;

    if (hourText.isNotEmpty) {
      final hour = int.tryParse(hourText);
      if (hour == null || hour < 1 || hour > 12) {
        isValid = false;
      }
    }

    if (minuteText.isNotEmpty) {
      final minute = int.tryParse(minuteText);
      if (minute == null || minute < 0 || minute > 59) {
        isValid = false;
      }
    }

    if (hourText.isEmpty || minuteText.isEmpty) {
      isValid = false;
    }

    setState(() {
      _isValidInput = isValid;
    });
  }

  void _onSetTime() {
    if (!_isValidInput) return;

    final hourText = _hourController.text;
    final minuteText = _minuteController.text;

    if (hourText.isEmpty || minuteText.isEmpty) {
      return;
    }

    final hour12 = int.tryParse(hourText);
    final minute = int.tryParse(minuteText);

    if (hour12 == null ||
        minute == null ||
        hour12 < 1 ||
        hour12 > 12 ||
        minute < 0 ||
        minute > 59) {
      return;
    }

    // Convert to 24-hour format
    int hour24;
    if (_isAM) {
      hour24 = hour12 == 12 ? 0 : hour12;
    } else {
      hour24 = hour12 == 12 ? 12 : hour12 + 12;
    }

    final now = DateTime.now();
    final selectedTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour24,
      minute,
    );

    // Haptic feedback for successful selection
    HapticFeedback.lightImpact();
    widget.onTimeSelected(selectedTime);
    Navigator.of(context).pop();
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  void _onAMPMToggle(bool isAM) {
    if (_isAM != isAM) {
      setState(() {
        _isAM = isAM;
      });
      // Haptic feedback for AM/PM toggle
      HapticFeedback.selectionClick();
    }
  }

  // Responsive helper functions
  double _getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth < 400) {
      return screenWidth * 0.9; // 90% on small screens
    } else if (screenWidth < 600) {
      return screenWidth * 0.8; // 80% on medium screens
    } else {
      return 400; // Fixed max width for larger screens
    }
  }

  double _getInputFieldSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth < 350) {
      return 60; // Smaller on very small screens
    } else if (screenWidth < 400) {
      return 70; // Medium size
    } else {
      return 80; // Default size
    }
  }

  double _getFontSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth < 350) {
      return 28; // Smaller font on very small screens
    } else if (screenWidth < 400) {
      return 32; // Medium font
    } else {
      return 36; // Default font size
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = _getDialogWidth(context);
    final inputFieldSize = _getInputFieldSize(context);
    final fontSize = _getFontSize(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          minWidth: 300,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 350 ? 16 : 24,
          vertical: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Set Time',
                    style: AppTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.sizeOf(context).width < 350 ? 18 : 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _onClose,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppTheme.secondaryText,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.sizeOf(context).width < 350 ? 24 : 32),

            // Time input section with responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Hour input
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            'Hour',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: inputFieldSize,
                            height: inputFieldSize,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isValidInput || _hourController.text.isEmpty
                                    ? AppTheme.greyDark
                                    : Colors.red.withOpacity(0.5),
                                width: _isValidInput || _hourController.text.isEmpty ? 1 : 2,
                              ),
                            ),
                            child: TextField(
                              controller: _hourController,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                                _HourInputFormatter(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Colon separator
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.sizeOf(context).width < 350 ? 8 : 16,
                      ),
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ),

                    // Minute input
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            'Minute',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: inputFieldSize,
                            height: inputFieldSize,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isValidInput || _minuteController.text.isEmpty
                                    ? AppTheme.greyDark
                                    : Colors.red.withValues(alpha: 0.5),
                                width: _isValidInput || _minuteController.text.isEmpty ? 1 : 2,
                              ),
                            ),
                            child: TextField(
                              controller: _minuteController,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                                _MinuteInputFormatter(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: MediaQuery.sizeOf(context).width < 350 ? 8 : 16),

                    // AM/PM toggle with enhanced visual feedback
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: GestureDetector(
                            onTap: () => _onAMPMToggle(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: MediaQuery.sizeOf(context).width < 350 ? 50 : 60,
                              height: MediaQuery.sizeOf(context).width < 350 ? 30 : 36,
                              decoration: BoxDecoration(
                                color: _isAM ? AppTheme.greyPrimary : AppTheme.greyDark,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                border: _isAM
                                    ? Border.all(
                                        color: AppTheme.primaryText.withOpacity(0.3),
                                        width: 1,
                                      )
                                    : null,
                                boxShadow: _isAM
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.greyPrimary.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'AM',
                                  style: TextStyle(
                                    fontSize: MediaQuery.sizeOf(context).width < 350 ? 12 : 14,
                                    fontWeight: _isAM ? FontWeight.bold : FontWeight.w600,
                                    color: _isAM ? AppTheme.primaryText : AppTheme.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: GestureDetector(
                            onTap: () => _onAMPMToggle(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: MediaQuery.sizeOf(context).width < 350 ? 50 : 60,
                              height: MediaQuery.sizeOf(context).width < 350 ? 30 : 36,
                              decoration: BoxDecoration(
                                color: !_isAM ? AppTheme.greyPrimary : AppTheme.greyDark,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                border: !_isAM
                                    ? Border.all(
                                        color: AppTheme.primaryText.withOpacity(0.3),
                                        width: 1,
                                      )
                                    : null,
                                boxShadow: !_isAM
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.greyPrimary.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'PM',
                                  style: TextStyle(
                                    fontSize: MediaQuery.sizeOf(context).width < 350 ? 12 : 14,
                                    fontWeight: !_isAM ? FontWeight.bold : FontWeight.w600,
                                    color: !_isAM ? AppTheme.primaryText : AppTheme.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: MediaQuery.sizeOf(context).width < 350 ? 24 : 32),

            // Set Time button with enhanced feedback
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: ElevatedButton(
                  onPressed: _isValidInput
                      ? () async {
                          await _buttonAnimationController.forward();
                          await _buttonAnimationController.reverse();
                          _onSetTime();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidInput 
                        ? AppTheme.greyPrimary 
                        : AppTheme.greyDark,
                    foregroundColor: _isValidInput 
                        ? AppTheme.primaryText 
                        : AppTheme.secondaryText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isValidInput ? 2 : 0,
                    shadowColor: _isValidInput 
                        ? AppTheme.greyPrimary.withOpacity(0.3) 
                        : Colors.transparent,
                  ),
                  child: Text(
                    'Set Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isValidInput 
                          ? AppTheme.primaryText 
                          : AppTheme.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Input formatter for hour field (1-12)
class _HourInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);
    if (value == null || value < 1 || value > 12) {
      return oldValue;
    }

    return newValue;
  }
}

/// Input formatter for minute field (0-59)
class _MinuteInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);
    if (value == null || value < 0 || value > 59) {
      return oldValue;
    }

    return newValue;
  }
}

/// Helper function to show the custom time picker modal
Future<void> showCustomTimePickerModal(
  BuildContext context, {
  DateTime? initialTime,
  required Function(DateTime?) onTimeSelected,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => CustomTimePickerModal(
      initialTime: initialTime,
      onTimeSelected: onTimeSelected,
    ),
  );
}
