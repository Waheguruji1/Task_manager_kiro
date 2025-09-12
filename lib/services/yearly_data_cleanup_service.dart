import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../utils/error_handler.dart';

/// Service for managing yearly data cleanup operations
/// 
/// This service automatically removes previous year's statistics and info data
/// while preserving task data and user preferences. It runs silently on app
/// startup and detects year transitions to trigger fresh data starts.
class YearlyDataCleanupService {
  static const String _lastCleanupYearKey = 'last_cleanup_year';
  
  final DatabaseService _databaseService;
  
  YearlyDataCleanupService(this._databaseService);
  
  /// Performs yearly data cleanup if needed
  /// 
  /// This method should be called during app startup. It will:
  /// - Check if cleanup is needed based on year transition
  /// - Remove previous year's statistics and achievement progress
  /// - Preserve task data and user settings
  /// - Run silently without user prompts
  /// 
  /// Returns true if cleanup was performed, false if not needed
  Future<bool> performCleanupIfNeeded() async {
    try {
      final currentYear = DateTime.now().year;
      final shouldCleanup = await _shouldPerformCleanup(currentYear);
      
      if (!shouldCleanup) {
        return false;
      }
      
      ErrorHandler.logInfo('Starting yearly data cleanup for year $currentYear');
      
      // Perform the cleanup operations
      await _cleanupPreviousYearData(currentYear);
      
      // Update the last cleanup year
      await _updateLastCleanupYear(currentYear);
      
      ErrorHandler.logInfo('Yearly data cleanup completed successfully');
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Yearly data cleanup', type: ErrorType.database);
      // Don't throw - cleanup failures shouldn't break app startup
      return false;
    }
  }
  
  /// Checks if cleanup should be performed
  /// 
  /// Cleanup is needed if:
  /// - This is the first time running cleanup
  /// - The current year is different from the last cleanup year
  Future<bool> _shouldPerformCleanup(int currentYear) async {
    try {
      final lastCleanupYear = await _getLastCleanupYear();
      
      // If no previous cleanup recorded, or year has changed, cleanup is needed
      return lastCleanupYear == null || lastCleanupYear < currentYear;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check cleanup needed', type: ErrorType.preferences);
      // If we can't determine, err on the side of performing cleanup
      return true;
    }
  }
  
  /// Performs the actual cleanup operations
  /// 
  /// This method:
  /// - Removes achievement progress (resets to unearned state)
  /// - Preserves task data (as per requirements)
  /// - Preserves user settings and preferences
  Future<void> _cleanupPreviousYearData(int currentYear) async {
    try {
      // Reset all achievement progress to start fresh for the new year
      // This preserves the achievement definitions but resets progress
      await _resetAchievementProgress();
      
      // Note: We intentionally preserve task data as per requirements
      // Task data includes both completed and incomplete tasks from previous years
      // This allows users to maintain their historical task records
      
      ErrorHandler.logInfo('Achievement progress reset for new year');
    } catch (e) {
      ErrorHandler.logError(e, context: 'Cleanup previous year data', type: ErrorType.database);
      rethrow;
    }
  }
  
  /// Resets all achievement progress for the new year
  /// 
  /// This sets all achievements back to unearned state with zero progress,
  /// allowing users to earn them again in the new year
  Future<void> _resetAchievementProgress() async {
    try {
      // Use the database's built-in method to reset all achievements
      // This resets both progress and earned status
      final resetCount = await _databaseService.database.resetAllAchievements();
      
      ErrorHandler.logInfo('Reset $resetCount achievements for new year');
    } catch (e) {
      ErrorHandler.logError(e, context: 'Reset achievement progress', type: ErrorType.database);
      rethrow;
    }
  }
  
  /// Gets the year of the last cleanup operation
  Future<int?> _getLastCleanupYear() async {
    try {
      // Use a custom method to get integer preference
      return await _getIntPreference(_lastCleanupYearKey);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get last cleanup year', type: ErrorType.preferences);
      return null;
    }
  }
  
  /// Updates the last cleanup year in preferences
  Future<void> _updateLastCleanupYear(int year) async {
    try {
      // Use a custom method to set integer preference
      await _setIntPreference(_lastCleanupYearKey, year);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Update last cleanup year', type: ErrorType.preferences);
      rethrow;
    }
  }
  
  /// Helper method to get integer preference
  Future<int?> _getIntPreference(String key) async {
    try {
      // Access SharedPreferences directly since we need int operations
      final sharedPrefs = await SharedPreferences.getInstance();
      return sharedPrefs.getInt(key);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get int preference', type: ErrorType.preferences);
      return null;
    }
  }
  
  /// Helper method to set integer preference
  Future<void> _setIntPreference(String key, int value) async {
    try {
      // Access SharedPreferences directly since we need int operations
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.setInt(key, value);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Set int preference', type: ErrorType.preferences);
      rethrow;
    }
  }
  
  /// Gets information about data that would be cleaned up
  /// 
  /// This method provides statistics about what data exists and what would
  /// be affected by cleanup. Useful for debugging and monitoring.
  /// 
  /// Returns a map with cleanup statistics
  Future<Map<String, dynamic>> getCleanupInfo() async {
    try {
      final currentYear = DateTime.now().year;
      final shouldCleanup = await _shouldPerformCleanup(currentYear);
      final lastCleanupYear = await _getLastCleanupYear();
      
      // Get achievement statistics
      final totalAchievements = await _databaseService.getTotalAchievementCount();
      final earnedAchievements = await _databaseService.getEarnedAchievementCount();
      
      // Get task statistics (for informational purposes)
      final allTasks = await _databaseService.getAllTasks();
      final currentYearTasks = allTasks.where((task) {
        return task.createdAt.year == currentYear;
      }).length;
      
      return {
        'currentYear': currentYear,
        'lastCleanupYear': lastCleanupYear,
        'shouldPerformCleanup': shouldCleanup,
        'totalAchievements': totalAchievements,
        'earnedAchievements': earnedAchievements,
        'totalTasks': allTasks.length,
        'currentYearTasks': currentYearTasks,
        'previousYearTasks': allTasks.length - currentYearTasks,
      };
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get cleanup info', type: ErrorType.database);
      return {
        'error': 'Failed to get cleanup information',
        'currentYear': DateTime.now().year,
      };
    }
  }
  
  /// Forces a cleanup operation regardless of year
  /// 
  /// This method is primarily for testing and debugging purposes.
  /// It will perform cleanup even if it's not needed based on year transition.
  /// 
  /// Returns true if cleanup was successful
  Future<bool> forceCleanup() async {
    try {
      final currentYear = DateTime.now().year;
      
      ErrorHandler.logInfo('Forcing yearly data cleanup for year $currentYear');
      
      await _cleanupPreviousYearData(currentYear);
      await _updateLastCleanupYear(currentYear);
      
      ErrorHandler.logInfo('Forced yearly data cleanup completed successfully');
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Force cleanup', type: ErrorType.database);
      return false;
    }
  }
  
  /// Gets the data retention cutoff date
  /// 
  /// This returns the date before which statistics data should be cleaned up.
  /// Currently set to the beginning of the current year.
  DateTime getDataRetentionCutoff() {
    final currentYear = DateTime.now().year;
    return DateTime(currentYear, 1, 1);
  }
}