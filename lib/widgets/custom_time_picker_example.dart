import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'custom_time_picker_modal.dart';

/// Example widget demonstrating the custom time picker usage
class CustomTimePickerExample extends StatefulWidget {
  const CustomTimePickerExample({super.key});

  @override
  State<CustomTimePickerExample> createState() => _CustomTimePickerExampleState();
}

class _CustomTimePickerExampleState extends State<CustomTimePickerExample> {
  DateTime? _selectedTime;

  void _showTimePicker() {
    showCustomTimePickerModal(
      context,
      initialTime: _selectedTime,
      onTimeSelected: (DateTime? time) {
        setState(() {
          _selectedTime = time;
        });
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Custom Time Picker Demo'),
        backgroundColor: AppTheme.backgroundDark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              margin: const EdgeInsets.all(AppTheme.spacingM),
              decoration: AppTheme.taskContainerDecoration,
              child: Column(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 48,
                    color: AppTheme.greyPrimary,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    _selectedTime != null 
                        ? 'Selected Time: ${_formatTime(_selectedTime!)}'
                        : 'No time selected',
                    style: AppTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  ElevatedButton(
                    onPressed: _showTimePicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greyPrimary,
                      foregroundColor: AppTheme.primaryText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                        vertical: AppTheme.spacingM,
                      ),
                    ),
                    child: const Text('Set Time'),
                  ),
                  if (_selectedTime != null) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedTime = null;
                        });
                      },
                      child: Text(
                        'Clear Time',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}