/// App Constants and String Literals
/// 
/// This file contains all the constant values and string literals used
/// throughout the Task Manager app to ensure consistency and easy maintenance.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'Task Manager';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A simple and elegant task management app';

  // SharedPreferences Keys
  static const String userNameKey = 'user_name';
  static const String firstLaunchKey = 'first_launch';
  static const String lastResetDateKey = 'last_reset_date';

  // Database Constants
  static const String databaseName = 'task_manager.db';
  static const int databaseVersion = 1;

  // UI Constants
  static const double minTouchTargetSize = 44.0;
  static const double recommendedTouchTargetSize = 48.0;
  static const int maxTaskTitleLength = 255;
  static const int maxTaskDescriptionLength = 1000;
  static const int maxUserNameLength = 50;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Validation Constants
  static const int minUserNameLength = 1;
  static const int minTaskTitleLength = 1;
}

/// String Literals used throughout the app
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // Welcome Screen
  static const String welcomeTitle = 'Welcome to ${AppConstants.appName}';
  static const String welcomeSubtitle = 'Let\'s get started by knowing your name';
  static const String nameInputHint = 'Enter your name';
  static const String nameInputLabel = 'Your Name';
  static const String continueButton = 'Continue';
  static const String getStartedButton = 'Get Started';

  // Home Screen
  static const String greetingMorning = 'Good morning';
  static const String greetingAfternoon = 'Good afternoon';
  static const String greetingEvening = 'Good evening';
  static const String greetingDefault = 'Hello';
  static const String todayLabel = 'Today';
  static const String everydayTasksTab = 'Everyday Tasks';
  static const String routineTasksTab = 'Routine Tasks';

  // Task Management
  static const String addTaskTitle = 'Add New Task';
  static const String editTaskTitle = 'Edit Task';
  static const String taskTitleHint = 'Enter task title';
  static const String taskTitleLabel = 'Task Title';
  static const String taskDescriptionHint = 'Enter task description (optional)';
  static const String taskDescriptionLabel = 'Description';
  static const String routineTaskLabel = 'Routine Task';
  static const String routineTaskHint = 'This task will repeat daily';
  static const String saveTaskButton = 'Save Task';
  static const String updateTaskButton = 'Update Task';
  static const String cancelButton = 'Cancel';
  static const String deleteButton = 'Delete';
  static const String editButton = 'Edit';

  // Task Status
  static const String taskCompleted = 'Task completed';
  static const String taskIncomplete = 'Task incomplete';
  static const String noTasksMessage = 'No tasks yet. Tap + to add your first task!';
  static const String noEverydayTasksMessage = 'No everyday tasks. Add some to get started!';
  static const String noRoutineTasksMessage = 'No routine tasks. Create routines to stay consistent!';

  // Confirmation Dialogs
  static const String deleteTaskTitle = 'Delete Task';
  static const String deleteTaskMessage = 'Are you sure you want to delete this task? This action cannot be undone.';
  static const String confirmButton = 'Confirm';

  // Error Messages
  static const String errorGeneral = 'Something went wrong. Please try again.';
  static const String errorDatabaseConnection = 'Unable to connect to database. Please restart the app.';
  static const String errorDatabaseLocked = 'Database is temporarily locked. Please try again.';
  static const String errorDatabaseCorrupted = 'Database appears to be corrupted. Please restart the app.';
  static const String errorDatabaseConstraint = 'Invalid data provided. Please check your input.';
  static const String errorPreferences = 'Failed to save settings. Please try again.';
  static const String errorValidation = 'Please check your input and try again.';
  static const String errorSavingTask = 'Failed to save task. Please try again.';
  static const String errorLoadingTasks = 'Failed to load tasks. Please try again.';
  static const String errorDeletingTask = 'Failed to delete task. Please try again.';
  static const String errorUpdatingTask = 'Failed to update task. Please try again.';
  static const String errorSavingUserName = 'Failed to save your name. Please try again.';
  static const String errorLoadingUserName = 'Failed to load your name.';

  // Validation Messages
  static const String validationNameRequired = 'Please enter your name';
  static const String validationNameTooLong = 'Name must be less than ${AppConstants.maxUserNameLength} characters';
  static const String validationTaskTitleRequired = 'Please enter a task title';
  static const String validationTaskTitleTooLong = 'Task title must be less than ${AppConstants.maxTaskTitleLength} characters';
  static const String validationTaskDescriptionTooLong = 'Description must be less than ${AppConstants.maxTaskDescriptionLength} characters';

  // Share Messages
  static const String shareAppText = '${AppConstants.appName} - ${AppConstants.appDescription}\n\nDownload now!';
  static const String shareTaskText = 'Check out my task: ';

  // Accessibility Labels
  static const String accessibilityAddTask = 'Add new task';
  static const String accessibilityEditTask = 'Edit task';
  static const String accessibilityDeleteTask = 'Delete task';
  static const String accessibilityCompleteTask = 'Mark task as complete';
  static const String accessibilityIncompleteTask = 'Mark task as incomplete';
  static const String accessibilityShareApp = 'Share app';
  static const String accessibilityBackButton = 'Go back';
  static const String accessibilityCloseDialog = 'Close dialog';

  // Date Formatting
  static const String dateFormatFull = 'EEEE, MMMM d, yyyy';
  static const String dateFormatShort = 'MMM d';
  static const String dateFormatDay = 'EEEE';
  static const String todayText = 'Today';
  static const String yesterdayText = 'Yesterday';
  static const String tomorrowText = 'Tomorrow';

  // Loading States
  static const String loadingTasks = 'Loading tasks...';
  static const String savingTask = 'Saving task...';
  static const String deletingTask = 'Deleting task...';
  static const String updatingTask = 'Updating task...';

  // Empty States
  static const String emptyStateTitle = 'Nothing here yet';
  static const String emptyStateSubtitle = 'Start by adding your first task';
  static const String emptyStateAction = 'Add Task';

  // Success Messages
  static const String taskSavedSuccess = 'Task saved successfully';
  static const String taskUpdatedSuccess = 'Task updated successfully';
  static const String taskDeletedSuccess = 'Task deleted successfully';
  static const String taskCompletedSuccess = 'Great job! Task completed';

  // Time-based Messages
  static const String routineTaskResetMessage = 'Routine tasks have been reset for today';
  static const String dailyMotivation = 'You\'ve got this! Let\'s make today productive.';
}

/// Icon Constants
class AppIcons {
  // Private constructor to prevent instantiation
  AppIcons._();

  // Navigation Icons
  static const String add = 'add';
  static const String share = 'share';
  static const String back = 'arrow_back';
  static const String forward = 'arrow_forward';
  static const String close = 'close';

  // Task Icons
  static const String checkbox = 'check_box_outline_blank';
  static const String checkboxChecked = 'check_box';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String routine = 'repeat';

  // Status Icons
  static const String completed = 'check_circle';
  static const String incomplete = 'radio_button_unchecked';
  static const String error = 'error_outline';
  static const String warning = 'warning';
  static const String info = 'info_outline';

  // Time Icons
  static const String today = 'today';
  static const String calendar = 'calendar_month';
  static const String time = 'access_time';
}

/// Route Names for Navigation
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
}

/// Asset Paths
class AppAssets {
  // Private constructor to prevent instantiation
  AppAssets._();

  // Fonts
  static const String sourGummyFont = 'assets/fonts/SourGummy-Regular.ttf';

  // Images (for future use)
  static const String appLogo = 'assets/images/app_logo.png';
  static const String emptyState = 'assets/images/empty_state.png';
}