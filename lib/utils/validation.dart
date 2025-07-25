import 'constants.dart';

/// Input validation utility class
/// 
/// Provides centralized validation methods for user inputs
/// throughout the app to ensure consistency and proper error handling.
class ValidationUtils {
  ValidationUtils._();

  /// Validate username input
  static String? validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationNameRequired;
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < AppConstants.minUserNameLength) {
      return AppStrings.validationNameRequired;
    }
    
    if (trimmedValue.length > AppConstants.maxUserNameLength) {
      return AppStrings.validationNameTooLong;
    }
    
    // Check for invalid characters (optional - basic validation)
    if (trimmedValue.contains(RegExp(r'[<>"/\\|?*]'))) {
      return 'Name contains invalid characters';
    }
    
    return null;
  }

  /// Validate task title input
  static String? validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.validationTaskTitleRequired;
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < AppConstants.minTaskTitleLength) {
      return AppStrings.validationTaskTitleRequired;
    }
    
    if (trimmedValue.length > AppConstants.maxTaskTitleLength) {
      return AppStrings.validationTaskTitleTooLong;
    }
    
    return null;
  }

  /// Validate task description input
  static String? validateTaskDescription(String? value) {
    if (value == null) return null; // Description is optional
    
    if (value.length > AppConstants.maxTaskDescriptionLength) {
      return AppStrings.validationTaskDescriptionTooLong;
    }
    
    return null;
  }

  /// Validate task ID for database operations
  static String? validateTaskId(int? id) {
    if (id == null || id <= 0) {
      return 'Invalid task ID';
    }
    
    return null;
  }

  /// Validate date string format
  static String? validateDateString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date cannot be empty';
    }
    
    try {
      // Try to parse the date to validate format
      DateTime.parse(value.trim());
      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  /// Sanitize user input by trimming and removing potentially harmful characters
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>"/\\|?*]'), '') // Remove potentially harmful characters
        .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
  }

  /// Check if a string is a valid non-empty string
  static bool isValidNonEmptyString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Check if a string exceeds maximum length
  static bool exceedsMaxLength(String? value, int maxLength) {
    return value != null && value.length > maxLength;
  }

  /// Check if a string is below minimum length
  static bool belowMinLength(String? value, int minLength) {
    return value == null || value.trim().length < minLength;
  }

  /// Validate email format (for future use)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate phone number format (for future use)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validate that a value is not null or empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  /// Validate numeric input
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid number';
    }
    
    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;
    
    final number = double.parse(value!.trim());
    if (number <= 0) {
      return '$fieldName must be a positive number';
    }
    
    return null;
  }
}

/// Form validation helper class
/// 
/// Provides methods to validate entire forms and handle validation states
class FormValidationHelper {
  FormValidationHelper._();

  /// Validate task form data
  static Map<String, String?> validateTaskForm({
    required String? title,
    String? description,
  }) {
    final errors = <String, String?>{};
    
    final titleError = ValidationUtils.validateTaskTitle(title);
    if (titleError != null) {
      errors['title'] = titleError;
    }
    
    final descriptionError = ValidationUtils.validateTaskDescription(description);
    if (descriptionError != null) {
      errors['description'] = descriptionError;
    }
    
    return errors;
  }

  /// Validate user registration form data
  static Map<String, String?> validateUserForm({
    required String? name,
  }) {
    final errors = <String, String?>{};
    
    final nameError = ValidationUtils.validateUserName(name);
    if (nameError != null) {
      errors['name'] = nameError;
    }
    
    return errors;
  }

  /// Check if form has any validation errors
  static bool hasErrors(Map<String, String?> errors) {
    return errors.values.any((error) => error != null);
  }

  /// Get first error message from validation errors
  static String? getFirstError(Map<String, String?> errors) {
    for (final error in errors.values) {
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}