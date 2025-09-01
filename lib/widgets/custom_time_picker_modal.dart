import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

/// Custom time picker modal matching the provided design
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

class _CustomTimePickerModalState extends State<CustomTimePickerModal> {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  bool _isAM = true;
  
  @override
  void initState() {
    super.initState();
    
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
    _minuteController = TextEditingController(text: initialTime.minute.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _onSetTime() {
    final hourText = _hourController.text;
    final minuteText = _minuteController.text;
    
    if (hourText.isEmpty || minuteText.isEmpty) {
      return;
    }
    
    final hour12 = int.tryParse(hourText);
    final minute = int.tryParse(minuteText);
    
    if (hour12 == null || minute == null || 
        hour12 < 1 || hour12 > 12 || 
        minute < 0 || minute > 59) {
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
    
    widget.onTimeSelected(selectedTime);
    Navigator.of(context).pop();
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set Time',
                  style: AppTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: AppTheme.secondaryText,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Time input section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Hour input
                Column(
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.greyDark,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _hourController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
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
                
                // Colon separator
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ),
                
                // Minute input
                Column(
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.greyDark,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _minuteController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
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
                
                const SizedBox(width: 16),
                
                // AM/PM toggle
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isAM = true),
                      child: Container(
                        width: 60,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _isAM ? AppTheme.greyPrimary : AppTheme.greyDark,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'AM',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isAM ? AppTheme.primaryText : AppTheme.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isAM = false),
                      child: Container(
                        width: 60,
                        height: 36,
                        decoration: BoxDecoration(
                          color: !_isAM ? AppTheme.greyPrimary : AppTheme.greyDark,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'PM',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: !_isAM ? AppTheme.primaryText : AppTheme.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Set Time button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onSetTime,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greyPrimary,
                  foregroundColor: AppTheme.primaryText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Set Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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