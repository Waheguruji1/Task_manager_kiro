import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import '../utils/time_input_validator.dart';

/// Time Input Field Widget
/// 
/// A specialized text input field for entering notification times with real-time validation.
/// Extends CustomTextField functionality with time-specific validation and user feedback.
class TimeInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final Function(TimeValidationResult)? onTimeChanged;
  final TimeValidationResult? initialValidationResult;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const TimeInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.onTimeChanged,
    this.initialValidationResult,
    this.enabled = true,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  TimeValidationResult? _currentValidation;
  bool _hasUserInput = false;

  @override
  void initState() {
    super.initState();
    _currentValidation = widget.initialValidationResult;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final validation = TimeInputValidator.validateTimeInput(widget.controller.text);
    setState(() {
      _currentValidation = validation;
      _hasUserInput = true;
    });
    widget.onTimeChanged?.call(validation);
  }

  void _clearInput() {
    widget.controller.clear();
    setState(() {
      _hasUserInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.text,
          textInputAction: widget.textInputAction,
          validator: (_) => _getValidationError(),
          inputFormatters: [
            // Allow digits, colon, space, A, M, P (for AM/PM)
            FilteringTextInputFormatter.allow(RegExp(r'[0-9:APMapm\s]')),
          ],
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: AppTheme.surfaceGrey,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingM,
            ),
            
            // iOS-style design with rounded corners, consistent with CustomTextField
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: BorderSide(
                color: AppTheme.greyPrimary,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: BorderSide.none,
            ),
            
            // Text styling consistent with CustomTextField
            hintStyle: const TextStyle(
              color: AppTheme.disabledText,
              fontFamily: AppTheme.primaryFontFamily,
              fontSize: 16,
            ),
            labelStyle: const TextStyle(
              color: AppTheme.secondaryText,
              fontFamily: AppTheme.primaryFontFamily,
              fontSize: 16,
            ),
            floatingLabelStyle: const TextStyle(
              color: AppTheme.primaryText,
              fontFamily: AppTheme.primaryFontFamily,
              fontSize: 14,
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontFamily: AppTheme.primaryFontFamily,
              fontSize: 12,
            ),
          ),
        ),
        if (_shouldShowHelperText()) ...[
          const SizedBox(height: AppTheme.spacingXS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Text(
              _getHelperText(),
              style: TextStyle(
                color: _getHelperTextColor(),
                fontSize: 12,
                fontFamily: AppTheme.primaryFontFamily,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuffixIcon() {
    if (widget.controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(
          Icons.clear,
          size: 20,
          color: AppTheme.secondaryText,
        ),
        onPressed: widget.enabled ? _clearInput : null,
        tooltip: 'Clear time',
      );
    }
    
    return const Icon(
      Icons.schedule,
      size: 20,
      color: AppTheme.secondaryText,
    );
  }

  String? _getValidationError() {
    // Only show validation errors if user has input and validation failed
    if (_hasUserInput && 
        _currentValidation != null && 
        !_currentValidation!.isValid && 
        !_currentValidation!.isEmpty) {
      return _currentValidation!.errorMessage;
    }
    return null;
  }

  bool _shouldShowHelperText() {
    return _currentValidation != null || !_hasUserInput;
  }

  String _getHelperText() {
    // If no user input yet, show format hint
    if (!_hasUserInput || _currentValidation == null || _currentValidation!.isEmpty) {
      return TimeInputValidator.timeFormatHint;
    }
    
    // If validation successful, show confirmation message
    if (_currentValidation!.isValid && !_currentValidation!.isEmpty) {
      final dateTime = _currentValidation!.toDateTime();
      if (dateTime != null) {
        final formattedTime = TimeInputValidator.formatTimeForDisplay(dateTime);
        final now = DateTime.now();
        final isNextDay = dateTime.day != now.day || dateTime.isBefore(now);
        
        return isNextDay 
            ? 'Reminder set for tomorrow at $formattedTime'
            : 'Reminder set for today at $formattedTime';
      }
    }
    
    // For invalid input, show format hint (error message is shown in validator)
    return TimeInputValidator.timeFormatHint;
  }

  Color _getHelperTextColor() {
    // If no user input or empty, show neutral color
    if (!_hasUserInput || _currentValidation == null || _currentValidation!.isEmpty) {
      return AppTheme.secondaryText;
    }
    
    // If validation successful, show success color
    if (_currentValidation!.isValid) {
      return AppTheme.greyPrimary;
    }
    
    // For invalid input, show neutral color (error color is handled by validator)
    return AppTheme.secondaryText;
  }
}