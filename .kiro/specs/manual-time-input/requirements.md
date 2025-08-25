# Manual Time Input for Notifications - Requirements Document

## Introduction

This document outlines the requirements for replacing the current time picker dialog with a single manual text input field for notification time setting in the task manager app. The current implementation uses a time picker dialog which should be completely removed and replaced with only a simple text input field where users can manually type the notification time. There will be only one method for time input - manual text entry.

## Requirements

### Requirement 1

**User Story:** As a user, I want to manually type the notification time instead of using a time picker dialog, so that I can quickly enter the exact time I want to be reminded.

#### Acceptance Criteria

1. WHEN creating or editing a task THEN the system SHALL provide ONLY a text input field for notification time (no time picker dialog)
2. WHEN the user taps on the notification time field THEN the system SHALL focus the text input field for manual typing (no time picker dialog shall open)
3. WHEN the user types in the notification time field THEN the system SHALL accept time in HH:MM format (24-hour or 12-hour with AM/PM)
4. WHEN the user enters a valid time format THEN the system SHALL parse and store the notification time correctly
5. WHEN the user enters an invalid time format THEN the system SHALL show validation error messages
6. WHEN the notification time field is empty THEN the system SHALL treat it as no notification set
7. WHEN the user clears the notification time field THEN the system SHALL remove any existing notification time
8. WHEN displaying existing notification time THEN the system SHALL show the time in a readable format in the text field
9. WHEN the system is implemented THEN there SHALL be no time picker dialog available - only manual text input

### Requirement 2

**User Story:** As a user, I want clear validation and feedback when entering notification times, so that I know if my input is correct and understand any errors.

#### Acceptance Criteria

1. WHEN the user enters time in HH:MM format THEN the system SHALL accept both 24-hour (e.g., "14:30") and 12-hour (e.g., "2:30 PM") formats
2. WHEN the user enters invalid time format THEN the system SHALL display specific error messages explaining the expected format
3. WHEN the user enters a time in the past for today THEN the system SHALL automatically schedule it for the next day
4. WHEN the user enters hours > 23 or minutes > 59 THEN the system SHALL show validation error
5. WHEN the user enters incomplete time (e.g., just "14") THEN the system SHALL show helpful validation message
6. WHEN the user enters time with invalid characters THEN the system SHALL show format error message
7. WHEN validation fails THEN the system SHALL prevent task saving until time is corrected or cleared
8. WHEN time is successfully parsed THEN the system SHALL provide visual confirmation of the accepted time

### Requirement 3

**User Story:** As a user, I want the manual time input to be intuitive and user-friendly, so that I can easily set notification times without confusion.

#### Acceptance Criteria

1. WHEN viewing the notification time field THEN the system SHALL show clear placeholder text indicating expected format
2. WHEN the field is focused THEN the system SHALL show helpful hint text about supported time formats
3. WHEN the user starts typing THEN the system SHALL provide real-time format validation feedback
4. WHEN the notification time is set THEN the system SHALL display a clear confirmation of when the notification will trigger
5. WHEN the user wants to clear the time THEN the system SHALL provide an easy way to clear the field (clear button or delete all text)
6. WHEN the field is empty THEN the system SHALL show placeholder text like "Enter time (e.g., 2:30 PM or 14:30)"
7. WHEN the user enters time THEN the system SHALL auto-format the display for consistency
8. WHEN the notification time input has focus THEN the system SHALL show the appropriate keyboard (numeric with colon/AM/PM if available)

### Requirement 4

**User Story:** As a developer, I want the manual time input implementation to be robust and maintainable, so that it integrates well with the existing codebase and handles edge cases properly.

#### Acceptance Criteria

1. WHEN implementing time parsing THEN the system SHALL use a dedicated validation utility function
2. WHEN time validation fails THEN the system SHALL provide specific error types for different validation failures
3. WHEN the user switches between routine and everyday tasks THEN the system SHALL properly show/hide the notification time field
4. WHEN editing existing tasks THEN the system SHALL populate the text field with the current notification time in readable format
5. WHEN the task is saved THEN the system SHALL convert the text input to proper DateTime object for storage
6. WHEN the component is disposed THEN the system SHALL properly clean up text controllers and listeners
7. WHEN the time input changes THEN the system SHALL update the internal state immediately for real-time validation
8. WHEN integrating with existing notification service THEN the system SHALL maintain compatibility with current scheduling logic