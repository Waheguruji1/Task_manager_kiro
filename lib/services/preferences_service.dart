import 'package:shared_preferences/shared_preferences.dart';
import '../utils/error_handler.dart';
import '../utils/constants.dart';

class PreferencesService {
  static const String _userNameKey = AppConstants.userNameKey;
  static const String _firstLaunchKey = AppConstants.firstLaunchKey;
  static const String _lastResetDateKey = AppConstants.lastResetDateKey;
  static const String _notificationsEnabledKey = AppConstants.notificationsEnabledKey;
  
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;
  
  static Future<PreferencesService> getInstance() async {
    try {
      _instance ??= PreferencesService._();
      _preferences ??= await SharedPreferences.getInstance();
      return _instance!;
    } catch (e) {
      ErrorHandler.logError(e, context: 'PreferencesService initialization', type: ErrorType.preferences);
      throw AppException(
        message: ErrorHandler.handlePreferencesError(e, context: 'PreferencesService initialization'),
        type: ErrorType.preferences,
        originalError: e,
      );
    }
  }
  
  PreferencesService._();
  
  /// Save the user's name to SharedPreferences
  Future<bool> saveUserName(String name) async {
    try {
      // Validate input
      if (name.trim().isEmpty) {
        throw AppException(
          message: AppStrings.validationNameRequired,
          type: ErrorType.validation,
        );
      }
      
      if (name.trim().length > AppConstants.maxUserNameLength) {
        throw AppException(
          message: AppStrings.validationNameTooLong,
          type: ErrorType.validation,
        );
      }
      
      return await _preferences!.setString(_userNameKey, name.trim());
    } catch (e) {
      ErrorHandler.logError(e, context: 'Save username', type: ErrorType.preferences);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handlePreferencesError(e, context: 'Save username'),
        type: ErrorType.preferences,
        originalError: e,
      );
    }
  }
  
  /// Retrieve the user's name from SharedPreferences
  Future<String?> getUserName() async {
    try {
      return _preferences!.getString(_userNameKey);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get username', type: ErrorType.preferences);
      throw AppException(
        message: ErrorHandler.handlePreferencesError(e, context: 'Get username'),
        type: ErrorType.preferences,
        originalError: e,
      );
    }
  }
  
  /// Check if this is the first launch of the app
  Future<bool> isFirstLaunch() async {
    try {
      return !(_preferences!.getBool(_firstLaunchKey) ?? false);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check first launch', type: ErrorType.preferences);
      // Return true as default for first launch check to be safe
      return true;
    }
  }
  
  /// Mark that the first launch has been completed
  Future<bool> setFirstLaunchComplete() async {
    try {
      return await _preferences!.setBool(_firstLaunchKey, true);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Set first launch complete', type: ErrorType.preferences);
      throw AppException(
        message: ErrorHandler.handlePreferencesError(e, context: 'Set first launch complete'),
        type: ErrorType.preferences,
        originalError: e,
      );
    }
  }
  
  /// Clear all user data from SharedPreferences
  Future<bool> clearUserData() async {
    try {
      await _preferences!.remove(_userNameKey);
      await _preferences!.remove(_firstLaunchKey);
      await _preferences!.remove(_lastResetDateKey);
      await _preferences!.remove(_notificationsEnabledKey);
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Clear user data', type: ErrorType.preferences);
      throw AppException(
        message: ErrorHandler.handlePreferencesError(e, context: 'Clear user data'),
        type: ErrorType.preferences,
        originalError: e,
      );
    }
  }
  
  /// Check if username exists in SharedPreferences
  Future<bool> hasUserName() async {
    try {
      final name = await getUserName();
      return name != null && name.trim().isNotEmpty;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check username exists', type: ErrorType.preferences);
      // Return false as default to be safe
      return false;
    }
  }
  
  /// Get the last reset date for routine tasks
  Future<String?> getLastResetDate() async {
    try {
      return _preferences!.getString(_lastResetDateKey);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get last reset date', type: ErrorType.preferences);
      // Return null as default for optional data
      return null;
    }
  }
  
  /// Set the last reset date for routine tasks
  Future<bool> setLastResetDate(String date) async {
    try {
      // Validate input
      if (date.trim().isEmpty) {
        throw AppException(
          message: 'Reset date cannot be empty',
          type: ErrorType.validation,
        );
      }
      
      return await _preferences!.setString(_lastResetDateKey, date.trim());
    } catch (e) {
      ErrorHandler.logError(e, context: 'Set last reset date', type: ErrorType.preferences);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handlePreferencesError(e, context: 'Set last reset date'),
        type: ErrorType.preferences,
        originalError: e,
      );
    }
  }

  /// Get notification enabled status
  Future<bool> areNotificationsEnabled() async {
    try {
      return _preferences!.getBool(_notificationsEnabledKey) ?? true; // Default to enabled
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get notifications enabled', type: ErrorType.preferences);
      // Return true as default to be safe
      return true;
    }
  }

  /// Set notification enabled status
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      return await _preferences!.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Set notifications enabled', type: ErrorType.preferences);
      throw AppException(
        message: ErrorHandler.handlePreferencesError(e, context: 'Set notifications enabled'),
        type: ErrorType.preferences,
        originalError: e,
      );
    }
  }
}