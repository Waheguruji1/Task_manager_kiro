# Implementation Plan

- [x] 1. Create time input validation utility and helper classes
- [x] 1.1 Create TimeInputValidator utility class
  - Create new file `lib/utils/time_input_validator.dart`
  - Implement regex patterns for 24-hour and 12-hour time formats
  - Add validateTimeInput() method with comprehensive validation logic
  - Implement formatTimeForDisplay() method for consistent time display
  - Add createNotificationDateTime() method to handle past time scheduling
  - Create detailed error message generation for different validation failures
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 4.1, 4.2_

- [x] 1.2 Create TimeValidationResult data class
  - Add TimeValidationResult class to handle validation states
  - Implement factory constructors for success, error, and empty states
  - Add toDateTime() method to convert valid results to DateTime objects
  - Include proper error message handling and state tracking
  - _Requirements: 2.2, 2.7, 4.2, 4.5_

- [x] 2. Create custom time input field widget
- [x] 2.1 Create TimeInputField widget
  - Create new file `lib/widgets/time_input_field.dart`
  - Extend functionality with real-time validation and user feedback
  - Implement onTimeChanged callback for parent component communication
  - Add helper text that shows validation status and confirmation messages
  - Include clear button functionality for easy input clearing
  - Add proper keyboard type and input action configuration
  - _Requirements: 1.1, 1.2, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.8_

- [x] 2.2 Integrate TimeInputField with existing CustomTextField styling
  - Ensure consistent theming with existing CustomTextField component
  - Add proper error state styling and validation message display
  - Implement suffix icon functionality (clear button and schedule icon)
  - Add helper text styling with color-coded validation feedback
  - _Requirements: 3.1, 3.2, 3.4, 3.7_

- [x] 3. Remove time picker dialog from AddTaskDialog
- [x] 3.1 Remove time picker dialog method and UI components
  - Delete _showNotificationTimePicker() method completely from AddTaskDialog
  - Remove the GestureDetector that opens the time picker dialog
  - Remove _notificationTimeController (replace with new time input controller)
  - Clean up any time picker related imports and dependencies
  - _Requirements: 1.1, 1.2, 1.9, 4.3_

- [x] 3.2 Replace time picker UI with TimeInputField
  - Replace the notification time GestureDetector section with TimeInputField widget
  - Add _notificationTimeInputController for the new text input field
  - Implement _onTimeInputChanged callback to handle validation results
  - Update the UI layout to use the new text input field instead of tap-to-open interface
  - _Requirements: 1.1, 1.2, 3.1, 3.6, 4.3_

- [x] 4. Update AddTaskDialog state management for manual time input
- [x] 4.1 Update dialog initialization for time input field
  - Modify _initializeDialog() to populate text field with existing notification time
  - Use TimeInputValidator.formatTimeForDisplay() for consistent time formatting
  - Initialize _timeValidationResult with proper validation state for existing tasks
  - Update disposal method to clean up new text controller
  - _Requirements: 1.8, 4.4, 4.6_

- [x] 4.2 Implement time input validation in form submission
  - Add _validateForm() method to check time input validity before saving
  - Update _saveTask() method to validate time input and show errors
  - Prevent task saving when time input is invalid (not empty but malformed)
  - Integrate time validation with existing form validation logic
  - _Requirements: 2.7, 4.7, 4.8_

- [x] 4.3 Update state management for real-time time input changes
  - Implement _onTimeInputChanged() callback to handle validation results
  - Update _notificationTime state based on validation results
  - Maintain previous valid time when user enters invalid input
  - Clear notification time when user clears the input field
  - _Requirements: 1.3, 1.4, 1.5, 1.6, 1.7, 4.7_

- [ ] 5. Add comprehensive testing for manual time input functionality
- [ ] 5.1 Create unit tests for TimeInputValidator
  - Test 24-hour format parsing (e.g., "14:30", "09:15", "23:59")
  - Test 12-hour format parsing (e.g., "2:30 PM", "11:45 AM", "12:00 AM")
  - Test invalid format handling (e.g., "25:70", "abc:def", "14:60")
  - Test empty input handling and edge cases
  - Test past time scheduling (should schedule for next day)
  - Test formatTimeForDisplay() method for consistent output
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [ ] 5.2 Create widget tests for TimeInputField
  - Test real-time validation feedback display
  - Test helper text updates based on validation state
  - Test clear button functionality
  - Test proper keyboard type and input actions
  - Test error message display for invalid inputs
  - Test success confirmation messages for valid inputs
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.8_

- [ ] 5.3 Create integration tests for AddTaskDialog time input
  - Test complete flow from manual time entry to task saving
  - Test editing existing tasks with notification times
  - Test form validation prevents saving with invalid time input
  - Test routine task toggle properly hides/shows time input field
  - Test time input field is properly cleared when switching to routine task
  - Verify notification scheduling works with manually entered times
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 4.3, 4.4, 4.5, 4.8_