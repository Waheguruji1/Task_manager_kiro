import '../models/task.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

/// Service for automatic cleanup of old completed everyday tasks
/// 
/// This service handles the automatic deletion of completed everyday tasks
/// that are older than 2 months to keep the database manageable and maintain
/// app performance. Routine tasks are excluded from cleanup to preserve
/// their template functionality.
class TaskCleanupService {
  static final TaskCleanupService _instance = TaskCleanupService._internal();
  factory TaskCleanupService() => _instance;
  TaskCleanupService._internal();

  /// Cleanup threshold in months - tasks older than this will be deleted
  static const int _cleanupThresholdMonths = 2;

  /// Perform automatic cleanup of old completed everyday tasks
  /// 
  /// This method identifies and deletes completed everyday tasks that are
  /// older than the cleanup threshold while preserving routine tasks and
  /// maintaining data integrity for statistics and achievements.
  /// 
  /// [databaseService] The database service instance to use for operations
  /// Returns true if cleanup was successful, false otherwise
  Future<bool> performCleanup(DatabaseService databaseService) async {
    try {
      ErrorHandler.logInfo(
        'Starting automatic task cleanup process',
        context: 'TaskCleanupService',
      );

      // Get all tasks to analyze for cleanup
      final allTasks = await databaseService.getAllTasks();
      
      // Identify tasks that should be cleaned up
      final tasksToCleanup = await getTasksToCleanup(allTasks);
      
      if (tasksToCleanup.isEmpty) {
        ErrorHandler.logInfo(
          'No tasks found for cleanup',
          context: 'TaskCleanupService',
        );
        return true;
      }

      // Perform the actual cleanup
      await cleanupOldTasks(tasksToCleanup, databaseService);
      
      ErrorHandler.logInfo(
        'Task cleanup completed successfully. Cleaned up ${tasksToCleanup.length} tasks',
        context: 'TaskCleanupService',
      );
      
      return true;
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Task cleanup process',
        type: ErrorType.database,
      );
      return false;
    }
  }

  /// Identify tasks that should be cleaned up
  /// 
  /// This method filters tasks based on the cleanup criteria:
  /// - Must be completed everyday tasks (not routine tasks)
  /// - Must be older than the cleanup threshold
  /// - Must have a completion date
  /// 
  /// [tasks] List of all tasks to analyze
  /// Returns list of tasks that should be deleted
  Future<List<Task>> getTasksToCleanup(List<Task> tasks) async {
    try {
      final cleanupThresholdDate = _getCleanupThresholdDate();
      final tasksToCleanup = <Task>[];

      for (final task in tasks) {
        if (_shouldCleanupTask(task, cleanupThresholdDate)) {
          tasksToCleanup.add(task);
        }
      }

      ErrorHandler.logInfo(
        'Identified ${tasksToCleanup.length} tasks for cleanup out of ${tasks.length} total tasks',
        context: 'TaskCleanupService',
      );

      return tasksToCleanup;
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Identify tasks for cleanup',
        type: ErrorType.unknown,
      );
      return [];
    }
  }

  /// Clean up old tasks by deleting them from the database
  /// 
  /// This method performs the actual deletion of tasks while maintaining
  /// data integrity and providing proper error handling and logging.
  /// 
  /// [tasksToDelete] List of tasks to delete
  /// [databaseService] Database service instance for operations
  Future<void> cleanupOldTasks(
    List<Task> tasksToDelete,
    DatabaseService databaseService,
  ) async {
    try {
      int successfulDeletions = 0;
      int failedDeletions = 0;

      // Delete tasks one by one to handle individual failures gracefully
      for (final task in tasksToDelete) {
        try {
          if (task.id != null) {
            final success = await databaseService.deleteTask(task.id!);
            if (success) {
              successfulDeletions++;
              ErrorHandler.logInfo(
                'Deleted task: "${task.title}" (ID: ${task.id}, Completed: ${task.completedAt})',
                context: 'TaskCleanupService',
              );
            } else {
              failedDeletions++;
              ErrorHandler.logError(
                'Failed to delete task with ID: ${task.id}',
                context: 'Task cleanup deletion',
                type: ErrorType.database,
              );
            }
          } else {
            failedDeletions++;
            ErrorHandler.logError(
              'Task has null ID, cannot delete: "${task.title}"',
              context: 'Task cleanup deletion',
              type: ErrorType.validation,
            );
          }
        } catch (e) {
          failedDeletions++;
          ErrorHandler.logError(
            e,
            context: 'Delete individual task during cleanup',
            type: ErrorType.database,
          );
        }
      }

      // Log cleanup summary
      await _logCleanupActivity(successfulDeletions, failedDeletions);

      if (failedDeletions > 0) {
        throw AppException(
          message: 'Some tasks could not be deleted during cleanup',
          type: ErrorType.database,
        );
      }
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Clean up old tasks',
        type: ErrorType.database,
      );
      rethrow;
    }
  }

  /// Check if a task should be cleaned up based on cleanup criteria
  /// 
  /// [task] The task to evaluate
  /// [thresholdDate] The cutoff date for cleanup
  /// Returns true if the task should be deleted, false otherwise
  bool _shouldCleanupTask(Task task, DateTime thresholdDate) {
    // Only cleanup completed everyday tasks
    if (!task.isCompleted || task.isRoutine) {
      return false;
    }

    // Task must have a completion date
    if (task.completedAt == null) {
      return false;
    }

    // Exclude routine task instances (tasks with routineTaskId)
    if (task.routineTaskId != null) {
      return false;
    }

    // Check if task is older than threshold
    return task.completedAt!.isBefore(thresholdDate);
  }

  /// Get the cleanup threshold date (current date minus cleanup threshold months)
  /// 
  /// Returns the date before which completed tasks should be cleaned up
  DateTime _getCleanupThresholdDate() {
    final now = DateTime.now();
    // Subtract the threshold months from current date
    final thresholdDate = DateTime(
      now.year,
      now.month - _cleanupThresholdMonths,
      now.day,
    );
    
    ErrorHandler.logInfo(
      'Cleanup threshold date: $thresholdDate ($_cleanupThresholdMonths months ago)',
      context: 'TaskCleanupService',
    );
    
    return thresholdDate;
  }

  /// Log cleanup activity for monitoring and debugging
  /// 
  /// [successfulDeletions] Number of tasks successfully deleted
  /// [failedDeletions] Number of tasks that failed to delete
  Future<void> _logCleanupActivity(
    int successfulDeletions,
    int failedDeletions,
  ) async {
    try {
      final totalAttempted = successfulDeletions + failedDeletions;
      final cleanupDate = DateTime.now();
      
      ErrorHandler.logInfo(
        'Cleanup Summary - Date: $cleanupDate, '
        'Total Attempted: $totalAttempted, '
        'Successful: $successfulDeletions, '
        'Failed: $failedDeletions, '
        'Threshold: $_cleanupThresholdMonths months',
        context: 'TaskCleanupService',
      );

      // In a production app, you might want to store cleanup logs in the database
      // or send them to an analytics service for monitoring
      
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Log cleanup activity',
        type: ErrorType.unknown,
      );
      // Don't rethrow here as logging failure shouldn't break cleanup
    }
  }

  /// Get cleanup statistics for monitoring purposes
  /// 
  /// [tasks] List of all tasks to analyze
  /// Returns a map with cleanup statistics
  Map<String, dynamic> getCleanupStatistics(List<Task> tasks) {
    try {
      final thresholdDate = _getCleanupThresholdDate();
      
      int totalTasks = tasks.length;
      int completedTasks = tasks.where((t) => t.isCompleted).length;
      int routineTasks = tasks.where((t) => t.isRoutine).length;
      int eligibleForCleanup = 0;
      int oldCompletedTasks = 0;

      for (final task in tasks) {
        if (task.isCompleted && task.completedAt != null) {
          if (task.completedAt!.isBefore(thresholdDate)) {
            oldCompletedTasks++;
            if (_shouldCleanupTask(task, thresholdDate)) {
              eligibleForCleanup++;
            }
          }
        }
      }

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'routineTasks': routineTasks,
        'oldCompletedTasks': oldCompletedTasks,
        'eligibleForCleanup': eligibleForCleanup,
        'thresholdDate': thresholdDate.toIso8601String(),
        'thresholdMonths': _cleanupThresholdMonths,
      };
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Get cleanup statistics',
        type: ErrorType.unknown,
      );
      return {
        'error': 'Failed to calculate cleanup statistics',
      };
    }
  }

  /// Check if cleanup is needed based on the number of old completed tasks
  /// 
  /// [tasks] List of all tasks to analyze
  /// [minimumTasksForCleanup] Minimum number of old tasks before cleanup is triggered
  /// Returns true if cleanup should be performed
  bool shouldPerformCleanup(List<Task> tasks, {int minimumTasksForCleanup = 10}) {
    try {
      final stats = getCleanupStatistics(tasks);
      final eligibleForCleanup = stats['eligibleForCleanup'] as int? ?? 0;
      
      final shouldCleanup = eligibleForCleanup >= minimumTasksForCleanup;
      
      ErrorHandler.logInfo(
        'Cleanup check - Eligible tasks: $eligibleForCleanup, '
        'Minimum threshold: $minimumTasksForCleanup, '
        'Should cleanup: $shouldCleanup',
        context: 'TaskCleanupService',
      );
      
      return shouldCleanup;
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Check if cleanup is needed',
        type: ErrorType.unknown,
      );
      return false;
    }
  }

  /// Perform cleanup only if needed (based on task count threshold)
  /// 
  /// This method checks if cleanup is necessary before performing it,
  /// which can help avoid unnecessary database operations.
  /// 
  /// [databaseService] The database service instance
  /// [minimumTasksForCleanup] Minimum number of old tasks before cleanup is triggered
  /// Returns true if cleanup was performed or not needed, false if cleanup failed
  Future<bool> performCleanupIfNeeded(
    DatabaseService databaseService, {
    int minimumTasksForCleanup = 10,
  }) async {
    try {
      final allTasks = await databaseService.getAllTasks();
      
      if (!shouldPerformCleanup(allTasks, minimumTasksForCleanup: minimumTasksForCleanup)) {
        ErrorHandler.logInfo(
          'Cleanup not needed at this time',
          context: 'TaskCleanupService',
        );
        return true;
      }
      
      return await performCleanup(databaseService);
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'Perform cleanup if needed',
        type: ErrorType.database,
      );
      return false;
    }
  }
}