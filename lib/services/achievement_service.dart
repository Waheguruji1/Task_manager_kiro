import '../models/task.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

/// Achievement Service for tracking progress and unlocking achievements
/// 
/// This service implements a singleton pattern and provides methods for:
/// - Calculating achievement progress based on task completion patterns
/// - Checking and unlocking achievements automatically
/// - Managing streak calculations for consecutive days and routine consistency
/// - Handling daily completion counting and milestone checking
/// - Persisting achievement updates to the database
class AchievementService {
  static AchievementService? _instance;
  DatabaseService? _databaseService;
  
  /// Private constructor for singleton pattern
  AchievementService._();
  
  /// Get singleton instance of AchievementService
  static Future<AchievementService> getInstance() async {
    _instance ??= AchievementService._();
    _instance!._databaseService ??= await DatabaseService.getInstance();
    return _instance!;
  }
  
  /// Initialize the service with database service
  Future<void> initialize() async {
    try {
      _databaseService ??= await DatabaseService.getInstance();
      await _databaseService!.initialize();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Achievement service initialization', type: ErrorType.unknown);
      throw AppException(
        message: 'Failed to initialize achievement service',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }
  
  // ==================== ACHIEVEMENT OPERATIONS ====================
  
  /// Get all achievements with current progress
  Future<List<Achievement>> getAllAchievements() async {
    try {
      await _ensureInitialized();
      return await _databaseService!.getAllAchievements();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get all achievements', type: ErrorType.database);
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to get achievements',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get earned achievements
  Future<List<Achievement>> getEarnedAchievements() async {
    try {
      await _ensureInitialized();
      return await _databaseService!.getEarnedAchievements();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get earned achievements', type: ErrorType.database);
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to get earned achievements',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get unearned achievements with progress
  Future<List<Achievement>> getUnearnedAchievements() async {
    try {
      await _ensureInitialized();
      return await _databaseService!.getUnearnedAchievements();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get unearned achievements', type: ErrorType.database);
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to get unearned achievements',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Check and update all achievements based on current task data
  /// This is the main method that should be called after task operations
  Future<List<Achievement>> checkAndUpdateAchievements() async {
    try {
      await _ensureInitialized();
      
      // Get all tasks for analysis
      final allTasks = await _databaseService!.getAllTasks();
      final completedTasks = allTasks.where((task) => task.isCompleted).toList();
      final routineTasks = allTasks.where((task) => task.isRoutine).toList();
      
      // Get all achievements to check
      final achievements = await _databaseService!.getAllAchievements();
      final newlyEarnedAchievements = <Achievement>[];
      
      for (final achievement in achievements) {
        if (achievement.isEarned) continue; // Skip already earned achievements
        
        bool shouldEarn = false;
        int newProgress = 0;
        
        switch (achievement.type) {
          case AchievementType.firstTime:
            shouldEarn = await _checkFirstTimeAchievements(completedTasks, achievement);
            newProgress = completedTasks.isNotEmpty ? 1 : 0;
            break;
            
          case AchievementType.streak:
            final currentStreak = await _calculateCurrentStreak(completedTasks);
            newProgress = currentStreak;
            shouldEarn = currentStreak >= achievement.targetValue;
            break;
            
          case AchievementType.dailyCompletion:
            final todayCompletions = await _getTodayCompletionCount(completedTasks);
            newProgress = todayCompletions;
            shouldEarn = todayCompletions >= achievement.targetValue;
            break;
            
          case AchievementType.routineConsistency:
            final routineStreak = await _calculateRoutineConsistencyStreak(allTasks, routineTasks);
            newProgress = routineStreak;
            shouldEarn = routineStreak >= achievement.targetValue;
            break;
            
          case AchievementType.weeklyCompletion:
            final weeklyCompletions = await _getWeeklyCompletionCount(completedTasks);
            newProgress = weeklyCompletions;
            shouldEarn = weeklyCompletions >= achievement.targetValue;
            break;
            
          case AchievementType.monthlyCompletion:
            final monthlyCompletions = await _getMonthlyCompletionCount(completedTasks);
            newProgress = monthlyCompletions;
            shouldEarn = monthlyCompletions >= achievement.targetValue;
            break;
        }
        
        // Update progress if it has changed
        if (newProgress != achievement.currentProgress) {
          await _databaseService!.updateAchievementProgress(achievement.id, newProgress);
        }
        
        // Unlock achievement if criteria met
        if (shouldEarn) {
          await _databaseService!.earnAchievement(achievement.id);
          final earnedAchievement = achievement.copyWith(
            isEarned: true,
            earnedAt: DateTime.now(),
            currentProgress: newProgress,
          );
          newlyEarnedAchievements.add(earnedAchievement);
        }
      }
      
      return newlyEarnedAchievements;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check and update achievements', type: ErrorType.unknown);
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to check and update achievements',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }
  
  /// Unlock a specific achievement manually
  Future<bool> unlockAchievement(String achievementId) async {
    try {
      await _ensureInitialized();
      
      if (achievementId.trim().isEmpty) {
        throw AppException(
          message: 'Achievement ID cannot be empty',
          type: ErrorType.validation,
        );
      }
      
      return await _databaseService!.earnAchievement(achievementId);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Unlock achievement', type: ErrorType.database);
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to unlock achievement',
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  // ==================== PROGRESS CALCULATION METHODS ====================
  
  /// Calculate current streak of consecutive days with completed tasks
  Future<int> calculateCurrentStreak(List<Task> tasks) async {
    try {
      return await _calculateCurrentStreak(tasks);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Calculate current streak', type: ErrorType.unknown);
      return 0;
    }
  }
  
  /// Calculate routine consistency streak (consecutive days with all routine tasks completed)
  Future<int> calculateRoutineStreak(List<Task> allTasks, List<Task> routineTasks) async {
    try {
      return await _calculateRoutineConsistencyStreak(allTasks, routineTasks);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Calculate routine streak', type: ErrorType.unknown);
      return 0;
    }
  }
  
  /// Get daily completion count for a specific date
  Future<int> getDailyCompletionCount(DateTime date, List<Task> tasks) async {
    try {
      return await _getDailyCompletionCount(date, tasks);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get daily completion count', type: ErrorType.unknown);
      return 0;
    }
  }
  
  /// Get today's completion count
  Future<int> getTodayCompletionCount(List<Task> tasks) async {
    try {
      return await _getTodayCompletionCount(tasks);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get today completion count', type: ErrorType.unknown);
      return 0;
    }
  }
  
  /// Check if first task completion achievement should be earned
  Future<bool> checkFirstTaskCompletion(List<Task> tasks) async {
    try {
      final firstTimeAchievements = await _databaseService!.getAchievementsByType(AchievementType.firstTime);
      if (firstTimeAchievements.isEmpty) return false;
      
      return await _checkFirstTimeAchievements(tasks, firstTimeAchievements.first);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check first task completion', type: ErrorType.unknown);
      return false;
    }
  }
  
  // ==================== PRIVATE HELPER METHODS ====================
  
  /// Ensure the service is properly initialized
  Future<void> _ensureInitialized() async {
    if (_databaseService == null) {
      await initialize();
    }
  }
  
  /// Calculate current streak of consecutive days with completed tasks
  Future<int> _calculateCurrentStreak(List<Task> completedTasks) async {
    if (completedTasks.isEmpty) return 0;
    
    // Group tasks by completion date
    final Map<DateTime, List<Task>> tasksByDate = {};
    for (final task in completedTasks) {
      if (task.completedAt != null) {
        final date = _normalizeDate(task.completedAt!);
        tasksByDate.putIfAbsent(date, () => []).add(task);
      }
    }
    
    if (tasksByDate.isEmpty) return 0;
    
    // Sort dates in descending order (most recent first) - dates are already available in tasksByDate.keys
    
    // Check if today has completed tasks
    final today = _normalizeDate(DateTime.now());
    if (!tasksByDate.containsKey(today)) return 0;
    
    // Count consecutive days starting from today
    int streak = 0;
    DateTime currentDate = today;
    
    while (tasksByDate.containsKey(currentDate)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
  
  /// Calculate routine consistency streak (consecutive days with all routine tasks completed)
  Future<int> _calculateRoutineConsistencyStreak(List<Task> allTasks, List<Task> routineTasks) async {
    if (routineTasks.isEmpty) return 0;
    
    // Get routine task IDs
    final routineTaskIds = routineTasks.map((task) => task.id).toSet();
    
    // Group completed routine tasks by date
    final Map<DateTime, Set<int?>> completedRoutinesByDate = {};
    
    for (final task in allTasks) {
      if (task.isCompleted && task.completedAt != null) {
        final date = _normalizeDate(task.completedAt!);
        
        // Check if this is a routine task or routine task instance
        if (task.isRoutine || (task.routineTaskId != null && routineTaskIds.contains(task.routineTaskId))) {
          completedRoutinesByDate.putIfAbsent(date, () => {}).add(task.routineTaskId ?? task.id);
        }
      }
    }
    
    // Count consecutive days where all routine tasks were completed
    int streak = 0;
    DateTime currentDate = _normalizeDate(DateTime.now());
    final totalRoutineCount = routineTasks.length;
    
    while (true) {
      final completedOnDate = completedRoutinesByDate[currentDate] ?? {};
      
      // Check if all routine tasks were completed on this date
      if (completedOnDate.length >= totalRoutineCount) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  /// Get completion count for today
  Future<int> _getTodayCompletionCount(List<Task> completedTasks) async {
    final today = _normalizeDate(DateTime.now());
    return await _getDailyCompletionCount(today, completedTasks);
  }
  
  /// Get completion count for a specific date
  Future<int> _getDailyCompletionCount(DateTime date, List<Task> completedTasks) async {
    final normalizedDate = _normalizeDate(date);
    
    return completedTasks.where((task) {
      if (task.completedAt == null) return false;
      final completedDate = _normalizeDate(task.completedAt!);
      return completedDate == normalizedDate;
    }).length;
  }
  
  /// Get completion count for current week
  Future<int> _getWeeklyCompletionCount(List<Task> completedTasks) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekNormalized = _normalizeDate(startOfWeek);
    final endOfWeekNormalized = startOfWeekNormalized.add(const Duration(days: 6));
    
    return completedTasks.where((task) {
      if (task.completedAt == null) return false;
      final completedDate = _normalizeDate(task.completedAt!);
      return completedDate.isAfter(startOfWeekNormalized.subtract(const Duration(days: 1))) &&
             completedDate.isBefore(endOfWeekNormalized.add(const Duration(days: 1)));
    }).length;
  }
  
  /// Get completion count for current month
  Future<int> _getMonthlyCompletionCount(List<Task> completedTasks) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return completedTasks.where((task) {
      if (task.completedAt == null) return false;
      final completedDate = task.completedAt!;
      return completedDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             completedDate.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).length;
  }
  
  /// Check first-time achievements
  Future<bool> _checkFirstTimeAchievements(List<Task> completedTasks, Achievement achievement) async {
    switch (achievement.id) {
      case 'first_task':
        return completedTasks.isNotEmpty;
      default:
        return false;
    }
  }
  
  /// Normalize date to remove time component for date comparisons
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  // ==================== ACHIEVEMENT CHECKING METHODS ====================
  // Note: Individual achievement checking methods are integrated into the main
  // checkAndUpdateAchievements method for better performance and consistency
  
  // ==================== UTILITY METHODS ====================
  
  /// Get achievement statistics
  Future<Map<String, dynamic>> getAchievementStats() async {
    try {
      await _ensureInitialized();
      
      final totalCount = await _databaseService!.getTotalAchievementCount();
      final earnedCount = await _databaseService!.getEarnedAchievementCount();
      final completionPercentage = totalCount > 0 ? (earnedCount / totalCount * 100).round() : 0;
      
      return {
        'total': totalCount,
        'earned': earnedCount,
        'remaining': totalCount - earnedCount,
        'completionPercentage': completionPercentage,
      };
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get achievement stats', type: ErrorType.database);
      return {
        'total': 0,
        'earned': 0,
        'remaining': 0,
        'completionPercentage': 0,
      };
    }
  }
  
  /// Reset all achievements (useful for testing)
  Future<bool> resetAllAchievements() async {
    try {
      await _ensureInitialized();
      final resetCount = await _databaseService!.database.resetAllAchievements();
      return resetCount > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Reset all achievements', type: ErrorType.database);
      return false;
    }
  }
  
  /// Get achievements that are close to being earned (within 80% of target)
  Future<List<Achievement>> getAlmostEarnedAchievements() async {
    try {
      await _ensureInitialized();
      final unearnedAchievements = await getUnearnedAchievements();
      
      return unearnedAchievements.where((achievement) {
        if (achievement.targetValue <= 0) return false;
        final progressPercentage = achievement.currentProgress / achievement.targetValue;
        return progressPercentage >= 0.8; // 80% or more progress
      }).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get almost earned achievements', type: ErrorType.unknown);
      return [];
    }
  }
  
  /// Dispose resources and reset singleton
  Future<void> dispose() async {
    try {
      _databaseService = null;
      _instance = null;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Dispose achievement service', type: ErrorType.unknown);
    }
  }
}