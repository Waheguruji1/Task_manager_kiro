/// Localization Support
/// 
/// This file provides a foundation for future localization support
/// Currently contains English strings, but can be extended for multiple languages

class AppLocalizations {
  // Private constructor to prevent instantiation
  AppLocalizations._();

  // Current locale (can be extended for multiple languages)
  static const String currentLocale = 'en';

  // Common UI strings
  static const Map<String, String> _strings = {
    // Navigation
    'back': 'Back',
    'next': 'Next',
    'done': 'Done',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'skip': 'Skip',
    'retry': 'Retry',
    'refresh': 'Refresh',
    'close': 'Close',
    'ok': 'OK',
    'yes': 'Yes',
    'no': 'No',

    // Time-related
    'today': 'Today',
    'yesterday': 'Yesterday',
    'tomorrow': 'Tomorrow',
    'morning': 'Morning',
    'afternoon': 'Afternoon',
    'evening': 'Evening',

    // Task-related
    'task': 'Task',
    'tasks': 'Tasks',
    'routine': 'Routine',
    'priority': 'Priority',
    'completed': 'Completed',
    'incomplete': 'Incomplete',
    'high_priority': 'High Priority',
    'medium_priority': 'Medium Priority',
    'low_priority': 'Low Priority',
    'no_priority': 'No Priority',

    // Status messages
    'loading': 'Loading...',
    'saving': 'Saving...',
    'deleting': 'Deleting...',
    'updating': 'Updating...',
    'success': 'Success',
    'error': 'Error',
    'warning': 'Warning',
    'info': 'Info',

    // Empty states
    'no_tasks': 'No tasks yet',
    'no_routine_tasks': 'No routine tasks',
    'no_completed_tasks': 'No completed tasks',
    'empty_state_message': 'Nothing here yet',

    // Notifications
    'notifications': 'Notifications',
    'notification_permission': 'Notification Permission',
    'enable_notifications': 'Enable Notifications',
    'disable_notifications': 'Disable Notifications',

    // Settings
    'settings': 'Settings',
    'preferences': 'Preferences',
    'about': 'About',
    'version': 'Version',
    'clear_data': 'Clear Data',
    'export_data': 'Export Data',
    'import_data': 'Import Data',

    // Achievements
    'achievements': 'Achievements',
    'earned': 'Earned',
    'progress': 'Progress',
    'milestone': 'Milestone',
    'streak': 'Streak',

    // Statistics
    'statistics': 'Statistics',
    'stats': 'Stats',
    'total': 'Total',
    'average': 'Average',
    'completion_rate': 'Completion Rate',
    'productivity': 'Productivity',

    // Errors
    'error_generic': 'Something went wrong',
    'error_network': 'Network error',
    'error_database': 'Database error',
    'error_permission': 'Permission denied',
    'error_not_found': 'Not found',
    'error_validation': 'Validation error',

    // Confirmation
    'confirm_delete': 'Are you sure you want to delete this?',
    'confirm_clear_data': 'This will permanently delete all your data',
    'action_cannot_be_undone': 'This action cannot be undone',

    // Accessibility
    'accessibility_button': 'Button',
    'accessibility_checkbox': 'Checkbox',
    'accessibility_text_field': 'Text field',
    'accessibility_menu': 'Menu',
    'accessibility_tab': 'Tab',
  };

  /// Get localized string by key
  static String get(String key) {
    return _strings[key] ?? key;
  }

  /// Get localized string with parameters
  static String getWithParams(String key, Map<String, String> params) {
    String text = get(key);
    params.forEach((param, value) {
      text = text.replaceAll('{$param}', value);
    });
    return text;
  }

  /// Check if a key exists
  static bool hasKey(String key) {
    return _strings.containsKey(key);
  }

  /// Get all available keys
  static List<String> getAllKeys() {
    return _strings.keys.toList();
  }

  /// Get current locale
  static String getLocale() {
    return currentLocale;
  }
}

/// Extension for easy access to localized strings
extension LocalizationExtension on String {
  /// Get localized string
  String get localized => AppLocalizations.get(this);
  
  /// Get localized string with parameters
  String localizedWithParams(Map<String, String> params) {
    return AppLocalizations.getWithParams(this, params);
  }
}

/// Commonly used localized strings as constants
class L10n {
  // Private constructor to prevent instantiation
  L10n._();

  // Navigation
  static String get back => AppLocalizations.get('back');
  static String get next => AppLocalizations.get('next');
  static String get done => AppLocalizations.get('done');
  static String get cancel => AppLocalizations.get('cancel');
  static String get save => AppLocalizations.get('save');
  static String get delete => AppLocalizations.get('delete');
  static String get edit => AppLocalizations.get('edit');
  static String get add => AppLocalizations.get('add');
  static String get skip => AppLocalizations.get('skip');
  static String get retry => AppLocalizations.get('retry');

  // Time
  static String get today => AppLocalizations.get('today');
  static String get yesterday => AppLocalizations.get('yesterday');
  static String get tomorrow => AppLocalizations.get('tomorrow');

  // Status
  static String get loading => AppLocalizations.get('loading');
  static String get success => AppLocalizations.get('success');
  static String get error => AppLocalizations.get('error');

  // Tasks
  static String get task => AppLocalizations.get('task');
  static String get tasks => AppLocalizations.get('tasks');
  static String get completed => AppLocalizations.get('completed');
  static String get noTasks => AppLocalizations.get('no_tasks');

  // Settings
  static String get settings => AppLocalizations.get('settings');
  static String get notifications => AppLocalizations.get('notifications');

  // Achievements
  static String get achievements => AppLocalizations.get('achievements');
  static String get stats => AppLocalizations.get('stats');
}