# Requirements Document

## Introduction

This document outlines the requirements for a personalized task manager Flutter app with a dark theme and custom typography. The app will feature a welcome screen for user personalization, a main task management interface, and an optional intro slider that can be implemented later with explicit permission.

## Requirements

### Requirement 1

**User Story:** As a new user, I want to enter my name on a welcome screen with proper design elements, so that the app feels personalized and addresses me by name throughout the experience.

#### Acceptance Criteria

1. WHEN the app is launched THEN the system SHALL check for saved username using shared_preferences package
2. IF username exists in shared preferences THEN the system SHALL navigate directly to the home screen
3. IF no username is found THEN the system SHALL display the welcome screen (welcome_screen.dart)
4. WHEN the welcome screen is displayed THEN the system SHALL show a container with the app logo and app name text
5. WHEN the welcome screen is rendered THEN the system SHALL display a text input field with boxy design, rounded corners, and white border of width 2px
6. WHEN the input field is displayed THEN the system SHALL follow the theme specifications for styling
7. WHEN the welcome screen is shown THEN the system SHALL include an elevated button on the right side with a forward arrow icon
8. WHEN the user enters their name and taps the forward button THEN the system SHALL save the username using shared_preferences package
9. WHEN the username is successfully saved THEN the system SHALL navigate to the main task manager screen
10. WHEN the app is launched on subsequent visits THEN the system SHALL retrieve the username from shared preferences and skip the welcome screen

### Requirement 2

**User Story:** As a user, I want to see a consistent AppBar across screens and a personalized greeting with my name on the home screen, so that the app feels welcoming and provides easy navigation.

#### Acceptance Criteria

1. WHEN any main screen is displayed THEN the system SHALL show an AppBar following the app theme specifications
2. WHEN the AppBar is rendered THEN the system SHALL display the app name on the left side
3. WHEN the AppBar is shown THEN the system SHALL include a share icon on the right side with share functionality
4. WHEN the user taps the share icon THEN the system SHALL open the device's share dialog to share the app
5. WHEN the home screen is displayed THEN the system SHALL show a personalized greeting message below the AppBar
6. WHEN the greeting is displayed THEN the system SHALL fetch the user's name from shared preferences
7. WHEN the user's name is retrieved THEN the system SHALL display it in the greeting format
8. WHEN the name cannot be retrieved THEN the system SHALL display a generic greeting
9. WHEN the greeting is shown THEN the system SHALL position it prominently on the home screen

### Requirement 3

**User Story:** As a user, I want to organize my tasks into everyday tasks and routine tasks using tabs, so that I can manage different types of activities separately.

#### Acceptance Criteria

1. WHEN the home screen is displayed THEN the system SHALL show two tabs below the greeting
2. WHEN the tabs are rendered THEN the system SHALL label them as "Everyday Tasks" and "Routine Tasks"
3. WHEN a tab is selected THEN the system SHALL display the corresponding task list
4. WHEN switching between tabs THEN the system SHALL maintain the current state of each tab
5. WHEN the app loads THEN the system SHALL default to the "Everyday Tasks" tab

### Requirement 4

**User Story:** As a user, I want routine tasks to be automatically added to my everyday tasks, so that I don't forget to complete my regular activities.

#### Acceptance Criteria

1. WHEN routine tasks exist THEN the system SHALL automatically include them in the everyday tasks list
2. WHEN a routine task is completed in everyday tasks THEN the system SHALL mark it as completed for that day only
3. WHEN a new day begins THEN the system SHALL reset routine task completion status and add them back to everyday tasks
4. WHEN viewing everyday tasks THEN the system SHALL visually distinguish routine tasks from regular everyday tasks
5. WHEN a routine task is deleted from the routine tasks tab THEN the system SHALL remove it from everyday tasks as well

### Requirement 5

**User Story:** As a user, I want to see my tasks displayed in modern, rounded rectangular containers with proper visual distinction, so that the interface looks clean and organized.

#### Acceptance Criteria

1. WHEN tasks are displayed THEN the system SHALL render them inside rounded rectangular containers
2. WHEN task containers are rendered THEN the system SHALL use a background color that provides subtle distinction from the dark background
3. WHEN task containers are displayed THEN the system SHALL apply rounded corners for a modern appearance
4. WHEN task containers are rendered THEN the system SHALL include a white border with 1px width
5. WHEN the task container is displayed THEN the system SHALL show the date of the day on which the task is assigned
6. WHEN multiple tasks exist THEN the system SHALL display all tasks for the day within the same container structure
7. WHEN the screen content exceeds viewport height THEN the system SHALL make the screen scrollable using SingleChildScrollView
8. WHEN the task container is displayed THEN the system SHALL include a plus icon for adding new tasks
9. WHEN each task is displayed THEN the system SHALL include a checkbox for marking completion status

### Requirement 6

**User Story:** As a user, I want to add, edit, and manage tasks in both everyday and routine categories, so that I can maintain control over my task organization.

#### Acceptance Criteria

1. WHEN the user taps the plus icon THEN the system SHALL display a dialog or form to add new tasks
2. WHEN viewing the everyday tasks tab THEN the system SHALL allow users to add new everyday tasks via the plus icon
3. WHEN viewing the routine tasks tab THEN the system SHALL allow users to add new routine tasks via the plus icon
4. WHEN a user taps a task checkbox THEN the system SHALL mark the task as complete or incomplete
5. WHEN a task checkbox is checked THEN the system SHALL visually indicate completion status
6. WHEN interacting with any task THEN the system SHALL allow users to edit task details
7. WHEN interacting with any task THEN the system SHALL allow users to delete tasks
8. WHEN adding tasks THEN the system SHALL provide appropriate input fields and validation
9. WHEN tasks are modified THEN the system SHALL persist changes locally using Drift database

### Requirement 7

**User Story:** As a user, I want the app to have a consistent dark theme with a grey/black/white color scheme and boxy design style, so that I have a modern and comfortable viewing experience with proper visual hierarchy.

#### Acceptance Criteria

1. WHEN the app is implemented THEN the system SHALL follow the comprehensive theme specifications defined in #[[file:theme.md]]
2. WHEN any screen is displayed THEN the system SHALL use dark grey as the primary background color
3. WHEN text is rendered THEN the system SHALL use white and its shades for text colors as defined in the theme
4. WHEN interactive elements need emphasis THEN the system SHALL use grey shades with white accents as specified in the theme
5. WHEN UI components are rendered THEN the system SHALL follow the boxy design style with smooth rounded corners
6. WHEN containers are displayed THEN the system SHALL use grey backgrounds with white borders of specified width
7. WHEN the app theme is applied THEN the system SHALL maintain consistent color usage across all screens using only black, grey, and white colors
8. WHEN displaying content THEN the system SHALL ensure sufficient contrast for accessibility compliance as outlined in the theme
9. WHEN implementing components THEN the system SHALL use the spacing system and typography specifications from the theme document

### Requirement 8

**User Story:** As a user, I want the app to use the Sour Gummy custom font, so that the interface has a unique and appealing typography.

#### Acceptance Criteria

1. WHEN any text is displayed THEN the system SHALL use the Sour Gummy font family
2. WHEN the custom font is not available THEN the system SHALL fallback to a suitable system font
3. WHEN text is rendered THEN the system SHALL maintain proper font weights and sizes for readability
4. WHEN the font is applied THEN the system SHALL ensure consistent typography across all screens

### Requirement 9

**User Story:** As a developer, I want to use Drift database for local data management, so that the app can efficiently store and retrieve user data, tasks, and preferences locally.

#### Acceptance Criteria

1. WHEN the app initializes THEN the system SHALL set up Drift database for local data storage
2. WHEN user data is stored THEN the system SHALL use Drift to persist user name and preferences
3. WHEN tasks are created, updated, or deleted THEN the system SHALL use Drift database operations
4. WHEN the app needs to query tasks THEN the system SHALL use Drift's query capabilities
5. WHEN the database schema needs updates THEN the system SHALL handle migrations properly
6. WHEN the app starts THEN the system SHALL initialize the database connection

### Requirement 10

**User Story:** As a developer, I want a well-organized project structure with proper component separation, so that the codebase is easy to navigate and maintain without unnecessary complexity.

#### Acceptance Criteria

1. WHEN the project is structured THEN the system SHALL organize files into logical directories (screens, widgets, services, models)
2. WHEN screen files are created THEN the system SHALL use descriptive names like welcome_screen.dart, home_screen.dart
3. WHEN components are developed THEN the system SHALL separate reusable widgets into dedicated widget files
4. WHEN services are implemented THEN the system SHALL create separate files for database operations, shared preferences, and other utilities
5. WHEN the project structure is designed THEN the system SHALL avoid complex architectural patterns like MVVM and keep it simple
6. WHEN organizing code THEN the system SHALL ensure each file has a single responsibility and clear purpose
7. WHEN creating the project structure THEN the system SHALL make it easy for developers to locate and modify specific functionality

### Requirement 11

**User Story:** As a user, I want to see visual heatmaps of my task completion activity over time, so that I can understand my productivity patterns and stay motivated through visual feedback.

#### Acceptance Criteria

1. WHEN the stats screen is displayed THEN the system SHALL show a task completion activity heatmap with purple color scheme
2. WHEN the completion heatmap is rendered THEN the system SHALL display a calendar-style grid showing daily task completion counts
3. WHEN the completion heatmap is shown THEN the system SHALL use varying shades of purple to indicate completion intensity (lighter for fewer tasks, darker for more tasks)
4. WHEN the stats screen is displayed THEN the system SHALL show a task creation vs completion heatmap with green color scheme
5. WHEN the creation vs completion heatmap is rendered THEN the system SHALL display both tasks created and completed per day
6. WHEN the creation vs completion heatmap is shown THEN the system SHALL use green color variations to show the balance between created and completed tasks
7. WHEN heatmaps are displayed THEN the system SHALL show data for the current year with monthly organization
8. WHEN a user interacts with heatmap cells THEN the system SHALL show tooltip information with specific counts for that day
9. WHEN heatmaps are rendered THEN the system SHALL handle empty days gracefully with appropriate neutral colors
10. WHEN the stats screen loads THEN the system SHALL calculate heatmap data from the task database efficiently

### Requirement 12

**User Story:** As a user, I want to earn and view achievements based on my task completion behavior, so that I feel motivated and rewarded for maintaining good productivity habits.

#### Acceptance Criteria

1. WHEN the stats screen is displayed THEN the system SHALL show an achievements section below the heatmaps
2. WHEN achievements are calculated THEN the system SHALL track task completion streaks and award streak-based achievements
3. WHEN achievements are evaluated THEN the system SHALL recognize daily completion milestones (5, 10, 20 tasks in a day)
4. WHEN achievements are processed THEN the system SHALL track weekly and monthly completion goals
5. WHEN achievements are determined THEN the system SHALL award achievements for routine task consistency
6. WHEN the achievements section is rendered THEN the system SHALL display earned achievements with icons, titles, and descriptions
7. WHEN achievements are shown THEN the system SHALL indicate progress toward unearned achievements
8. WHEN achievements are displayed THEN the system SHALL use visual indicators (badges, progress bars) to show achievement status
9. WHEN new achievements are earned THEN the system SHALL store achievement data persistently in the database
10. WHEN achievements are calculated THEN the system SHALL include achievements for: "First Task", "Week Warrior" (7 days streak), "Month Master" (30 days streak), "Routine Champion" (complete all routine tasks for 7 days), "Task Tornado" (20 tasks in one day)

### Requirement 13

**User Story:** As a user, I want to set priority levels for my everyday tasks with subtle visual distinction, so that I can focus on important tasks without visual clutter.

#### Acceptance Criteria

1. WHEN creating or editing an everyday task THEN the system SHALL provide priority options: High, Medium, or No Priority
2. WHEN the priority dropdown is displayed THEN the system SHALL open upward to save screen space
3. WHEN a task has High priority THEN the system SHALL display it with a purple tile background
4. WHEN a task has Medium priority THEN the system SHALL display it with a green tile background
5. WHEN a task has No Priority THEN the system SHALL display it with the current default styling
6. WHEN displaying everyday tasks THEN the system SHALL automatically sort them by priority (High → Medium → No Priority)
7. WHEN routine tasks are created or edited THEN the system SHALL NOT show priority options as they are always low priority
8. WHEN priority colors are applied THEN the system SHALL maintain subtle visual treatment without overwhelming the interface
9. WHEN priority is set THEN the system SHALL persist the priority level in the database
10. WHEN the priority system is implemented THEN the system SHALL ensure color accessibility and theme consistency

### Requirement 14

**User Story:** As a user, I want to set notification reminders for my everyday tasks, so that I don't forget important tasks without being overwhelmed by notifications.

#### Acceptance Criteria

1. WHEN creating or editing an everyday task THEN the system SHALL provide notification time options: 1hr, 2hr, or custom time
2. WHEN the notification dropdown is displayed THEN the system SHALL open upward to save screen space
3. WHEN a custom notification time is selected THEN the system SHALL allow the user to set a specific time
4. WHEN a notification time is set THEN the system SHALL schedule a local notification for that task
5. WHEN routine tasks are created or edited THEN the system SHALL NOT show notification options
6. WHEN the app is installed THEN the system SHALL request notification permissions from the user
7. WHEN a notification is triggered THEN the system SHALL display task details and allow quick completion
8. WHEN notification settings are changed THEN the system SHALL update or cancel existing scheduled notifications
9. WHEN notifications are set THEN the system SHALL persist notification preferences in the database
10. WHEN the user completes a task THEN the system SHALL automatically cancel any pending notifications for that task

### Requirement 15

**User Story:** As a user, I want a settings page to manage my notification preferences, so that I can control when and how I receive task reminders.

#### Acceptance Criteria

1. WHEN the settings screen is accessed THEN the system SHALL display notification management options
2. WHEN notification settings are displayed THEN the system SHALL show a toggle to enable/disable all notifications
3. WHEN notifications are disabled globally THEN the system SHALL cancel all scheduled notifications
4. WHEN notifications are re-enabled THEN the system SHALL reschedule notifications for tasks with notification times set
5. WHEN notification settings are changed THEN the system SHALL save preferences using SharedPreferences
6. WHEN the settings screen is displayed THEN the system SHALL show current notification permission status
7. WHEN notification permissions are denied THEN the system SHALL provide guidance to enable them in device settings
8. WHEN settings are updated THEN the system SHALL apply changes immediately without requiring app restart
9. WHEN the settings screen is accessed THEN the system SHALL maintain consistent theme and styling
10. WHEN notification preferences are saved THEN the system SHALL provide user feedback confirming the changes

### Requirement 16

**User Story:** As a user, I want long task titles and content to be properly truncated, so that the interface remains clean and readable without text overflow.

#### Acceptance Criteria

1. WHEN task titles exceed the available space THEN the system SHALL truncate them with ellipsis (...)
2. WHEN task descriptions are displayed THEN the system SHALL limit them to a maximum number of lines with truncation
3. WHEN text is truncated THEN the system SHALL allow users to tap to view the full content
4. WHEN truncation is applied THEN the system SHALL maintain consistent spacing and alignment
5. WHEN task containers are rendered THEN the system SHALL ensure text doesn't break the layout
6. WHEN truncated text is displayed THEN the system SHALL maintain readability and accessibility
7. WHEN text truncation is implemented THEN the system SHALL apply it consistently across all task displays
8. WHEN long content is shown THEN the system SHALL provide smooth transitions between truncated and full views
9. WHEN text is truncated THEN the system SHALL ensure important information remains visible
10. WHEN truncation is applied THEN the system SHALL maintain the app's visual hierarchy and theme

### Requirement 17

**User Story:** As a user, I want my completed everyday tasks to be automatically cleaned up after 2 months, so that my task list stays manageable and the app performs well.

#### Acceptance Criteria

1. WHEN everyday tasks are completed THEN the system SHALL track their completion date for cleanup purposes
2. WHEN the app performs maintenance THEN the system SHALL identify completed everyday tasks older than 2 months
3. WHEN old completed tasks are found THEN the system SHALL automatically delete them from the database
4. WHEN routine tasks are completed THEN the system SHALL NOT include them in the auto-deletion process
5. WHEN auto-deletion runs THEN the system SHALL preserve task statistics and achievement data
6. WHEN tasks are auto-deleted THEN the system SHALL update any related heatmap and stats data accordingly
7. WHEN the cleanup process runs THEN the system SHALL do so in the background without affecting user experience
8. WHEN auto-deletion is performed THEN the system SHALL log the cleanup activity for debugging purposes
9. WHEN the app starts THEN the system SHALL check if cleanup is needed and perform it if necessary
10. WHEN tasks are auto-deleted THEN the system SHALL ensure database integrity and proper cleanup of related data

### Requirement 18

**User Story:** As a developer, I want the option to implement an intro slider later with explicit permission, so that I can add onboarding features when appropriate without disrupting the current development flow.

#### Acceptance Criteria

1. WHEN the app architecture is designed THEN the system SHALL accommodate future integration of an intro slider
2. WHEN the intro slider is not implemented THEN the system SHALL function normally without it
3. WHEN the intro slider is later added THEN the system SHALL display it before the welcome screen
4. WHEN the intro slider is implemented THEN the system SHALL only show it on first app launch
5. IF the intro slider is added THEN the system SHALL provide a way to skip or complete the onboarding flow