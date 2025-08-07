import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import '../utils/error_handler.dart';

/// Task State
/// 
/// Represents the current state of tasks in the app
class TaskState {
  final List<Task> everydayTasks;
  final List<Task> routineTasks;
  final bool isLoading;
  final String? error;
  final List<Achievement> recentlyEarnedAchievements;
  final bool isAchievementProcessing;

  const TaskState({
    this.everydayTasks = const [],
    this.routineTasks = const [],
    this.isLoading = false,
    this.error,
    this.recentlyEarnedAchievements = const [],
    this.isAchievementProcessing = false,
  });

  TaskState copyWith({
    List<Task>? everydayTasks,
    List<Task>? routineTasks,
    bool? isLoading,
    String? error,
    List<Achievement>? recentlyEarnedAchievements,
    bool? isAchievementProcessing,
  }) {
    return TaskState(
      everydayTasks: everydayTasks ?? this.everydayTasks,
      routineTasks: routineTasks ?? this.routineTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recentlyEarnedAchievements: recentlyEarnedAchievements ?? this.recentlyEarnedAchievements,
      isAchievementProcessing: isAchievementProcessing ?? this.isAchievementProcessing,
    );
  }
}

/// Task State Notifier
/// 
/// Manages the state of tasks and provides methods for task operations
class TaskStateNotifier extends StateNotifier<TaskState> {
  final DatabaseService _databaseService;
  final AchievementService _achievementService;
  final NotificationService _notificationService;

  TaskStateNotifier(this._databaseService, this._achievementService, this._notificationService) : super(const TaskState()) {
    loadTasks();
  }

  /// Load all tasks from the database
  Future<void> loadTasks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final everydayTasks = await _databaseService.getEverydayTasks();
      final routineTasks = await _databaseService.getRoutineTasks();
      
      // Sort tasks by priority (High → Medium → No Priority)
      final sortedEverydayTasks = Task.sortByPriority(everydayTasks);
      final sortedRoutineTasks = Task.sortByPriority(routineTasks);
      
      state = state.copyWith(
        everydayTasks: sortedEverydayTasks,
        routineTasks: sortedRoutineTasks,
        isLoading: false,
      );
    } catch (e) {
      ErrorHandler.logError(e, context: 'Load tasks', type: ErrorType.database);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tasks: ${e.toString()}',
      );
    }
  }

  /// Add a new task
  Future<bool> addTask(Task task) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Schedule notification if task has notification time set
      int? notificationId;
      if (task.notificationTime != null && !task.isRoutine) {
        try {
          await _notificationService.initialize();
          notificationId = await _notificationService.scheduleTaskNotification(task);
          
          if (notificationId != null) {
            // Update task with notification ID
            task = task.copyWith(notificationId: notificationId);
          }
        } catch (e) {
          ErrorHandler.logError(e, context: 'Schedule notification for new task', type: ErrorType.notification);
          // Continue with task creation even if notification scheduling fails
        }
      }
      
      final taskId = await _databaseService.createTask(task);
      
      if (taskId > 0) {
        // Reload tasks to get the updated list
        await loadTasks();
        
        // Check and update achievements after task creation
        await _checkAndUpdateAchievements();
        
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Failed to add task');
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Add task', type: ErrorType.database);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add task: ${e.toString()}',
      );
      return false;
    }
  }

  /// Update an existing task
  Future<bool> updateTask(Task task) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get the original task to check for notification changes
      Task? originalTask;
      try {
        originalTask = await _databaseService.getTaskById(task.id!);
      } catch (e) {
        ErrorHandler.logError(e, context: 'Get original task for notification update', type: ErrorType.database);
      }
      
      // Handle notification scheduling/rescheduling for non-routine tasks
      if (!task.isRoutine) {
        try {
          await _notificationService.initialize();
          
          // Cancel existing notification if it exists
          if (originalTask?.notificationId != null) {
            await _notificationService.cancelTaskNotification(originalTask!.notificationId!);
          }
          
          // Schedule new notification if task has notification time set
          int? notificationId;
          if (task.notificationTime != null) {
            notificationId = await _notificationService.scheduleTaskNotification(task);
            
            if (notificationId != null) {
              // Update task with new notification ID
              task = task.copyWith(notificationId: notificationId);
            }
          } else {
            // Clear notification ID if no notification time is set
            task = task.copyWith(notificationId: null);
          }
        } catch (e) {
          ErrorHandler.logError(e, context: 'Reschedule notification for updated task', type: ErrorType.notification);
          // Continue with task update even if notification rescheduling fails
        }
      }
      
      final success = await _databaseService.updateTask(task);
      
      if (success) {
        // Reload tasks to get the updated list
        await loadTasks();
        
        // Check and update achievements after task update
        await _checkAndUpdateAchievements();
        
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Failed to update task');
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Update task', type: ErrorType.database);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update task: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete a task
  Future<bool> deleteTask(int taskId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get the task to check for notification cancellation before deletion
      Task? taskToDelete;
      try {
        taskToDelete = await _databaseService.getTaskById(taskId);
      } catch (e) {
        ErrorHandler.logError(e, context: 'Get task for notification cancellation', type: ErrorType.database);
      }
      
      // Cancel notification if task has one scheduled
      if (taskToDelete?.notificationId != null) {
        try {
          await _notificationService.initialize();
          await _notificationService.cancelTaskNotification(taskToDelete!.notificationId!);
        } catch (e) {
          ErrorHandler.logError(e, context: 'Cancel notification for deleted task', type: ErrorType.notification);
          // Continue with task deletion even if notification cancellation fails
        }
      }
      
      final success = await _databaseService.deleteTask(taskId);
      
      if (success) {
        // Reload tasks to get the updated list
        await loadTasks();
        
        // Check and update achievements after task deletion
        await _checkAndUpdateAchievements();
        
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Failed to delete task');
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Delete task', type: ErrorType.database);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete task: ${e.toString()}',
      );
      return false;
    }
  }

  /// Toggle task completion status
  Future<bool> toggleTaskCompletion(int taskId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get the task to check its current completion status and notification
      Task? taskToToggle;
      try {
        taskToToggle = await _databaseService.getTaskById(taskId);
      } catch (e) {
        ErrorHandler.logError(e, context: 'Get task for completion toggle', type: ErrorType.database);
      }
      
      final success = await _databaseService.toggleTaskCompletion(taskId);
      
      if (success) {
        // Handle notification cancellation when task is completed
        if (taskToToggle != null && !taskToToggle.isCompleted && taskToToggle.notificationId != null) {
          try {
            await _notificationService.initialize();
            await _notificationService.cancelTaskNotification(taskToToggle.notificationId!);
          } catch (e) {
            ErrorHandler.logError(e, context: 'Cancel notification for completed task', type: ErrorType.notification);
            // Continue even if notification cancellation fails
          }
        }
        
        // Reload tasks to get the updated list
        await loadTasks();
        
        // Check and update achievements after task completion toggle
        // This is especially important for streak and daily completion achievements
        await _checkAndUpdateAchievements();
        
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Failed to toggle task completion');
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Toggle task completion', type: ErrorType.database);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle task completion: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete routine task and all its instances
  Future<bool> deleteRoutineTaskAndInstances(int routineTaskId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _databaseService.deleteRoutineTaskAndInstances(routineTaskId);
      
      if (success) {
        // Reload tasks to get the updated list
        await loadTasks();
        
        // Check and update achievements after routine task deletion
        // This affects routine consistency achievements
        await _checkAndUpdateAchievements();
        
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Failed to delete routine task');
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Delete routine task and instances', type: ErrorType.database);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete routine task: ${e.toString()}',
      );
      return false;
    }
  }

  /// Reset daily routine tasks
  Future<bool> resetDailyRoutineTasks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _databaseService.resetDailyRoutineTasks();
      
      if (success) {
        // Reload tasks to get the updated list
        await loadTasks();
        
        // Check and update achievements after routine task reset
        // This affects routine consistency streaks
        await _checkAndUpdateAchievements();
        
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Failed to reset daily routine tasks');
      return false;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Reset daily routine tasks', type: ErrorType.database);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset daily routine tasks: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Check and update achievements after task operations
  /// 
  /// This method is called after each task operation to ensure real-time
  /// achievement progress updates and unlocking of new achievements
  Future<void> _checkAndUpdateAchievements() async {
    try {
      // Set achievement processing state to indicate background work
      state = state.copyWith(isAchievementProcessing: true);
      
      // Call the achievement service to check and update achievements
      // This will calculate streaks, daily completions, routine consistency, etc.
      final newlyEarnedAchievements = await _achievementService.checkAndUpdateAchievements();
      
      // Update state with newly earned achievements
      if (newlyEarnedAchievements.isNotEmpty) {
        state = state.copyWith(
          recentlyEarnedAchievements: newlyEarnedAchievements,
          isAchievementProcessing: false,
        );
        
        // Log newly earned achievements for debugging
        for (final achievement in newlyEarnedAchievements) {
          ErrorHandler.logInfo(
            'Achievement earned: ${achievement.title} - ${achievement.description}',
            context: 'Achievement tracking',
          );
        }
      } else {
        // No new achievements, just clear processing state
        state = state.copyWith(isAchievementProcessing: false);
      }
    } catch (e) {
      // Don't fail the main task operation if achievement checking fails
      // Just log the error and continue
      ErrorHandler.logError(
        e,
        context: 'Achievement checking after task operation',
        type: ErrorType.unknown,
      );
      
      // Clear achievement processing state even on error
      state = state.copyWith(isAchievementProcessing: false);
    }
  }

  /// Clear recently earned achievements from state
  /// This should be called after the UI has shown the achievements to the user
  void clearRecentlyEarnedAchievements() {
    state = state.copyWith(recentlyEarnedAchievements: []);
  }

  /// Get current streak information for achievements
  Future<Map<String, int>> getStreakInformation() async {
    try {
      final allTasks = [...state.everydayTasks, ...state.routineTasks];
      final completedTasks = allTasks.where((task) => task.isCompleted).toList();
      
      final currentStreak = await _achievementService.calculateCurrentStreak(completedTasks);
      final routineStreak = await _achievementService.calculateRoutineStreak(allTasks, state.routineTasks);
      final todayCompletions = await _achievementService.getTodayCompletionCount(completedTasks);
      
      return {
        'currentStreak': currentStreak,
        'routineStreak': routineStreak,
        'todayCompletions': todayCompletions,
      };
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Get streak information',
        type: ErrorType.unknown,
      );
      return {
        'currentStreak': 0,
        'routineStreak': 0,
        'todayCompletions': 0,
      };
    }
  }

  /// Force achievement recalculation
  /// This can be useful for debugging or manual achievement updates
  Future<void> forceAchievementUpdate() async {
    try {
      state = state.copyWith(isAchievementProcessing: true);
      
      // Force a complete achievement recalculation
      final newlyEarnedAchievements = await _achievementService.checkAndUpdateAchievements();
      
      state = state.copyWith(
        recentlyEarnedAchievements: newlyEarnedAchievements,
        isAchievementProcessing: false,
      );
      
      ErrorHandler.logInfo(
        'Forced achievement update completed. ${newlyEarnedAchievements.length} new achievements earned.',
        context: 'Achievement tracking',
      );
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Force achievement update',
        type: ErrorType.unknown,
      );
      state = state.copyWith(isAchievementProcessing: false);
    }
  }

  /// Check if routine tasks are consistently completed
  /// This is specifically for routine consistency achievement tracking
  Future<bool> checkRoutineConsistency() async {
    try {
      final allTasks = [...state.everydayTasks, ...state.routineTasks];
      final routineStreak = await _achievementService.calculateRoutineStreak(allTasks, state.routineTasks);
      
      // Log routine consistency information
      ErrorHandler.logInfo(
        'Current routine consistency streak: $routineStreak days',
        context: 'Routine consistency tracking',
      );
      
      return routineStreak > 0;
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Check routine consistency',
        type: ErrorType.unknown,
      );
      return false;
    }
  }

  /// Get daily completion statistics for achievement tracking
  Future<Map<String, dynamic>> getDailyCompletionStats() async {
    try {
      final allTasks = [...state.everydayTasks, ...state.routineTasks];
      final completedTasks = allTasks.where((task) => task.isCompleted).toList();
      
      final todayCompletions = await _achievementService.getTodayCompletionCount(completedTasks);
      final streakInfo = await getStreakInformation();
      
      return {
        'todayCompletions': todayCompletions,
        'currentStreak': streakInfo['currentStreak'] ?? 0,
        'routineStreak': streakInfo['routineStreak'] ?? 0,
        'totalCompletedTasks': completedTasks.length,
        'totalTasks': allTasks.length,
        'completionRate': allTasks.isEmpty ? 0.0 : (completedTasks.length / allTasks.length * 100).round(),
      };
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Get daily completion stats',
        type: ErrorType.unknown,
      );
      return {
        'todayCompletions': 0,
        'currentStreak': 0,
        'routineStreak': 0,
        'totalCompletedTasks': 0,
        'totalTasks': 0,
        'completionRate': 0.0,
      };
    }
  }

  /// Request notification permissions
  /// This should be called before scheduling notifications
  Future<bool> requestNotificationPermissions() async {
    try {
      await _notificationService.initialize();
      return await _notificationService.requestPermissions();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Request notification permissions', type: ErrorType.notification);
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      await _notificationService.initialize();
      return await _notificationService.areNotificationsEnabled();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check notification permissions', type: ErrorType.notification);
      return false;
    }
  }

  /// Reschedule all notifications for tasks
  /// This is useful when notification settings are changed globally
  Future<bool> rescheduleAllNotifications() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _notificationService.initialize();
      
      // Get all tasks with notification times
      final allTasks = [...state.everydayTasks, ...state.routineTasks];
      final tasksWithNotifications = allTasks.where((task) => 
        task.notificationTime != null && !task.isRoutine && !task.isCompleted
      ).toList();
      
      await _notificationService.rescheduleAllNotifications(tasksWithNotifications);
      
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Reschedule all notifications', type: ErrorType.notification);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reschedule notifications: ${e.toString()}',
      );
      return false;
    }
  }

  /// Cancel all notifications
  /// This is useful when notifications are disabled globally
  Future<bool> cancelAllNotifications() async {
    try {
      await _notificationService.initialize();
      await _notificationService.cancelAllNotifications();
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Cancel all notifications', type: ErrorType.notification);
      return false;
    }
  }

  /// Get pending notification count for debugging
  Future<int> getPendingNotificationCount() async {
    try {
      await _notificationService.initialize();
      final pendingNotifications = await _notificationService.getPendingNotifications();
      return pendingNotifications.length;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get pending notification count', type: ErrorType.notification);
      return 0;
    }
  }
}