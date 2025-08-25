/// Validation result for time input parsing
class TimeValidationResult {
  final bool isValid;
  final bool isEmpty;
  final int? hour;
  final int? minute;
  final String? errorMessage;
  
  const TimeValidationResult._({
    required this.isValid,
    required this.isEmpty,
    this.hour,
    this.minute,
    this.errorMessage,
  });
  
  /// Factory constructor for successful validation
  factory TimeValidationResult.success(int hour, int minute) {
    return TimeValidationResult._(
      isValid: true,
      isEmpty: false,
      hour: hour,
      minute: minute,
    );
  }
  
  /// Factory constructor for validation error
  factory TimeValidationResult.error(String message) {
    return TimeValidationResult._(
      isValid: false,
      isEmpty: false,
      errorMessage: message,
    );
  }
  
  /// Factory constructor for empty input
  factory TimeValidationResult.empty() {
    return const TimeValidationResult._(
      isValid: true,
      isEmpty: true,
    );
  }
  
  /// Convert valid result to DateTime object
  DateTime? toDateTime() {
    if (isValid && !isEmpty && hour != null && minute != null) {
      return TimeInputValidator.createNotificationDateTime(hour!, minute!);
    }
    return null;
  }
}

/// Utility class for validating and parsing time input strings
class TimeInputValidator {
  static const String timeFormatHint = 'Enter time (e.g., 2:30 PM or 14:30)';
  
  // Regex patterns for different time formats
  static final RegExp _twentyFourHourPattern = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5][0-9])$');
  static final RegExp _twelveHourPattern = RegExp(r'^(1[0-2]|0?[1-9]):([0-5][0-9])\s*(AM|PM|am|pm)$');
  
  /// Validates and parses time input string
  static TimeValidationResult validateTimeInput(String input) {
    if (input.trim().isEmpty) {
      return TimeValidationResult.empty();
    }
    
    final trimmedInput = input.trim();
    
    // Try 24-hour format first
    final match24 = _twentyFourHourPattern.firstMatch(trimmedInput);
    if (match24 != null) {
      final hour = int.parse(match24.group(1)!);
      final minute = int.parse(match24.group(2)!);
      return TimeValidationResult.success(hour, minute);
    }
    
    // Try 12-hour format
    final match12 = _twelveHourPattern.firstMatch(trimmedInput);
    if (match12 != null) {
      int hour = int.parse(match12.group(1)!);
      final minute = int.parse(match12.group(2)!);
      final period = match12.group(3)!.toUpperCase();
      
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      
      return TimeValidationResult.success(hour, minute);
    }
    
    // Invalid format
    return TimeValidationResult.error(_getFormatErrorMessage(trimmedInput));
  }
  
  /// Convert DateTime to display format (12-hour with AM/PM)
  static String formatTimeForDisplay(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    if (hour == 0) {
      return '12:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour < 12) {
      return '$hour:${minute.toString().padLeft(2, '0')} AM';
    } else if (hour == 12) {
      return '12:${minute.toString().padLeft(2, '0')} PM';
    } else {
      return '${hour - 12}:${minute.toString().padLeft(2, '0')} PM';
    }
  }
  
  /// Create DateTime from validated time input, handling past times
  static DateTime createNotificationDateTime(int hour, int minute) {
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If time is in the past, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      return scheduledTime.add(const Duration(days: 1));
    }
    
    return scheduledTime;
  }
  
  /// Generate detailed error messages for different validation failures
  static String _getFormatErrorMessage(String input) {
    if (input.contains(':')) {
      if (input.split(':').length != 2) {
        return 'Use format HH:MM (e.g., 14:30 or 2:30 PM)';
      }
      
      final parts = input.split(':');
      final hourPart = parts[0].trim();
      final minutePart = parts[1].trim().split(' ')[0]; // Remove AM/PM for validation
      
      if (!RegExp(r'^\d+$').hasMatch(hourPart)) {
        return 'Hour must be a number';
      }
      
      if (!RegExp(r'^\d+$').hasMatch(minutePart)) {
        return 'Minute must be a number';
      }
      
      final hour = int.tryParse(hourPart);
      final minute = int.tryParse(minutePart);
      
      if (hour == null || hour < 0 || hour > 23) {
        return 'Hour must be between 0-23 (or 1-12 with AM/PM)';
      }
      
      if (minute == null || minute < 0 || minute > 59) {
        return 'Minute must be between 0-59';
      }
      
      // Check for AM/PM format issues
      if (input.toUpperCase().contains('AM') || input.toUpperCase().contains('PM')) {
        if (hour > 12) {
          return 'Use 1-12 with AM/PM or 0-23 for 24-hour format';
        }
        if (hour == 0) {
          return 'Use 12 AM instead of 0 AM';
        }
      }
      
      return 'Invalid time format. Use HH:MM or H:MM AM/PM';
    }
    
    return 'Use format HH:MM (e.g., 14:30 or 2:30 PM)';
  }
}