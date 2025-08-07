import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../models/database.dart';
import '../models/task.dart';
import '../models/achievement.dart';
import '../utils/error_handler.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;
  
  static Future<DatabaseService> getInstance() async {
    _instance ??= DatabaseService._();
    _database ??= AppDatabase();
    return _instance!;
  }
  
  DatabaseService._();
  
  AppDatabase get database => _database!;
  
  /// Initialize the database
  Future<void> initialize() async {
    try {
      _database ??= AppDatabase();
      // Test database connection
      await _database!.select(_database!.tasks).get();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Database initialization', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Database initialization'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Create a new task
  Future<int> createTask(Task task) async {
    try {
      // Validate task data
      if (task.title.trim().isEmpty) {
        throw AppException(
          message: 'Task title cannot be empty',
          type: ErrorType.validation,
        );
      }
      
      final companion = TasksCompanion(
        title: Value(task.title.trim()),
        description: Value(task.description?.trim()),
        isCompleted: Value(task.isCompleted),
        isRoutine: Value(task.isRoutine),
        createdAt: Value(task.createdAt),
        completedAt: Value(task.completedAt),
        routineTaskId: Value(task.routineTaskId),
        taskDate: Value(task.taskDate),
        priority: Value(task.priority.index),
        notificationTime: Value(task.notificationTime),
        notificationId: Value(task.notificationId),
      );
      
      return await _database!.into(_database!.tasks).insert(companion);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Create task', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Create task'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Read all tasks
  Future<List<Task>> getAllTasks() async {
    try {
      final taskDataList = await _database!.select(_database!.tasks).get();
      return taskDataList.map((taskData) => _taskDataToTask(taskData)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get all tasks', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get all tasks'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Read everyday tasks (includes regular tasks and daily routine task instances)
  Future<List<Task>> getEverydayTasks() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // Get regular everyday tasks (non-routine tasks)
      final regularTasksQuery = _database!.select(_database!.tasks)
        ..where((t) => t.isRoutine.equals(false) & t.routineTaskId.isNull());
      final regularTasks = await regularTasksQuery.get();
      
      // Get today's routine task instances
      final routineInstancesQuery = _database!.select(_database!.tasks)
        ..where((t) => t.routineTaskId.isNotNull() & t.taskDate.equals(todayStart));
      final routineInstances = await routineInstancesQuery.get();
      
      // Combine both lists
      final allTasks = [...regularTasks, ...routineInstances];
      return allTasks.map((taskData) => _taskDataToTask(taskData)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get everyday tasks', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get everyday tasks'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Read routine tasks
  Future<List<Task>> getRoutineTasks() async {
    try {
      final query = _database!.select(_database!.tasks)
        ..where((t) => t.isRoutine.equals(true));
      final taskDataList = await query.get();
      return taskDataList.map((taskData) => _taskDataToTask(taskData)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get routine tasks', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get routine tasks'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Update an existing task
  Future<bool> updateTask(Task task) async {
    try {
      if (task.id == null) {
        throw AppException(
          message: 'Task ID cannot be null for update operation',
          type: ErrorType.validation,
        );
      }
      
      // Validate task data
      if (task.title.trim().isEmpty) {
        throw AppException(
          message: 'Task title cannot be empty',
          type: ErrorType.validation,
        );
      }
      
      final companion = TasksCompanion(
        id: Value(task.id!),
        title: Value(task.title.trim()),
        description: Value(task.description?.trim()),
        isCompleted: Value(task.isCompleted),
        isRoutine: Value(task.isRoutine),
        createdAt: Value(task.createdAt),
        completedAt: Value(task.completedAt),
        routineTaskId: Value(task.routineTaskId),
        taskDate: Value(task.taskDate),
        priority: Value(task.priority.index),
        notificationTime: Value(task.notificationTime),
        notificationId: Value(task.notificationId),
      );
      
      final updatedRows = await (_database!.update(_database!.tasks)
            ..where((t) => t.id.equals(task.id!)))
          .write(companion);
      
      return updatedRows > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Update task', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Update task'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Delete a task by ID
  Future<bool> deleteTask(int id) async {
    try {
      if (id <= 0) {
        throw AppException(
          message: 'Invalid task ID for delete operation',
          type: ErrorType.validation,
        );
      }
      
      final deletedRows = await (_database!.delete(_database!.tasks)
            ..where((t) => t.id.equals(id)))
          .go();
      
      return deletedRows > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Delete task', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Delete task'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Toggle task completion status
  Future<bool> toggleTaskCompletion(int id) async {
    try {
      if (id <= 0) {
        throw AppException(
          message: 'Invalid task ID for toggle operation',
          type: ErrorType.validation,
        );
      }
      
      // First, get the current task
      final query = _database!.select(_database!.tasks)
        ..where((t) => t.id.equals(id));
      final taskData = await query.getSingleOrNull();
      
      if (taskData == null) {
        throw AppException(
          message: 'Task not found',
          type: ErrorType.validation,
        );
      }
      
      // Toggle completion status
      final newCompletionStatus = !taskData.isCompleted;
      final now = DateTime.now();
      
      final companion = TasksCompanion(
        id: Value(id),
        isCompleted: Value(newCompletionStatus),
        completedAt: Value(newCompletionStatus ? now : null),
      );
      
      final updatedRows = await (_database!.update(_database!.tasks)
            ..where((t) => t.id.equals(id)))
          .write(companion);
      
      return updatedRows > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Toggle task completion', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Toggle task completion'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get a specific task by ID
  Future<Task?> getTaskById(int id) async {
    try {
      if (id <= 0) {
        throw AppException(
          message: 'Invalid task ID',
          type: ErrorType.validation,
        );
      }
      
      final query = _database!.select(_database!.tasks)
        ..where((t) => t.id.equals(id));
      final taskData = await query.getSingleOrNull();
      
      if (taskData == null) return null;
      return _taskDataToTask(taskData);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get task by ID', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get task by ID'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Create daily instances of routine tasks for today
  Future<bool> createDailyRoutineTaskInstances() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // Get all routine task templates
      final routineTasksQuery = _database!.select(_database!.tasks)
        ..where((t) => t.isRoutine.equals(true) & t.routineTaskId.isNull());
      final routineTasks = await routineTasksQuery.get();
      
      // Check which routine tasks already have instances for today
      final existingInstancesQuery = _database!.select(_database!.tasks)
        ..where((t) => t.routineTaskId.isNotNull() & t.taskDate.equals(todayStart));
      final existingInstances = await existingInstancesQuery.get();
      final existingRoutineIds = existingInstances.map((t) => t.routineTaskId).toSet();
      
      // Create instances for routine tasks that don't have instances today
      for (final routineTask in routineTasks) {
        if (!existingRoutineIds.contains(routineTask.id)) {
          final instanceCompanion = TasksCompanion(
            title: Value(routineTask.title),
            description: Value(routineTask.description),
            isCompleted: const Value(false),
            isRoutine: const Value(false), // Instance is not a routine task itself
            createdAt: Value(DateTime.now()),
            completedAt: const Value(null),
            routineTaskId: Value(routineTask.id),
            taskDate: Value(todayStart),
            priority: Value(routineTask.priority), // Inherit priority from routine task
            notificationTime: Value(routineTask.notificationTime), // Inherit notification settings
            notificationId: Value(routineTask.notificationId),
          );
          
          await _database!.into(_database!.tasks).insert(instanceCompanion);
        }
      }
      
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Create daily routine task instances', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Create daily routine task instances'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  /// Delete routine task and all its instances
  Future<bool> deleteRoutineTaskAndInstances(int routineTaskId) async {
    try {
      if (routineTaskId <= 0) {
        throw AppException(
          message: 'Invalid routine task ID for delete operation',
          type: ErrorType.validation,
        );
      }
      
      // Delete all instances of this routine task
      await (_database!.delete(_database!.tasks)
            ..where((t) => t.routineTaskId.equals(routineTaskId)))
          .go();
      
      // Delete the routine task template itself
      final deletedRows = await (_database!.delete(_database!.tasks)
            ..where((t) => t.id.equals(routineTaskId)))
          .go();
      
      return deletedRows > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Delete routine task and instances', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Delete routine task and instances'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  /// Reset daily routine tasks (create new instances for new day)
  Future<bool> resetDailyRoutineTasks() async {
    try {
      // Create daily instances for today
      await createDailyRoutineTaskInstances();
      return true;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Reset daily routine tasks', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Reset daily routine tasks'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get today's routine tasks (for display in everyday tasks)
  Future<List<Task>> getTodaysRoutineTasks() async {
    try {
      final routineTasks = await getRoutineTasks();
      // For now, return all routine tasks as they should appear in everyday tasks
      // In a more complex implementation, you might filter by date or other criteria
      return routineTasks;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get today\'s routine tasks', type: ErrorType.database);
      return [];
    }
  }

  // ==================== PRIORITY-BASED OPERATIONS ====================

  /// Get everyday tasks sorted by priority
  Future<List<Task>> getEverydayTasksSortedByPriority() async {
    try {
      final taskDataList = await _database!.getEverydayTasksSortedByPriority();
      return taskDataList.map((taskData) => _taskDataToTask(taskData)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get everyday tasks sorted by priority', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get everyday tasks sorted by priority'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  /// Get tasks by priority level
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    try {
      final taskDataList = await _database!.getTasksByPriority(priority.index);
      return taskDataList.map((taskData) => _taskDataToTask(taskData)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get tasks by priority', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get tasks by priority'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  // ==================== NOTIFICATION-BASED OPERATIONS ====================

  /// Get tasks with scheduled notifications
  Future<List<Task>> getTasksWithNotifications() async {
    try {
      final taskDataList = await _database!.getTasksWithNotifications();
      return taskDataList.map((taskData) => _taskDataToTask(taskData)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get tasks with notifications', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get tasks with notifications'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  /// Get tasks with notifications scheduled for a specific date
  Future<List<Task>> getTasksWithNotificationsForDate(DateTime date) async {
    try {
      final taskDataList = await _database!.getTasksWithNotificationsForDate(date);
      return taskDataList.map((taskData) => _taskDataToTask(taskData)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get tasks with notifications for date', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get tasks with notifications for date'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  /// Get task by notification ID
  Future<Task?> getTaskByNotificationId(int notificationId) async {
    try {
      if (notificationId <= 0) {
        throw AppException(
          message: 'Invalid notification ID',
          type: ErrorType.validation,
        );
      }

      final taskData = await _database!.getTaskByNotificationId(notificationId);
      if (taskData == null) return null;
      return _taskDataToTask(taskData);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get task by notification ID', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get task by notification ID'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  /// Update task notification settings
  Future<bool> updateTaskNotification(int taskId, DateTime? notificationTime, int? notificationId) async {
    try {
      if (taskId <= 0) {
        throw AppException(
          message: 'Invalid task ID for notification update',
          type: ErrorType.validation,
        );
      }

      final companion = TasksCompanion(
        id: Value(taskId),
        notificationTime: Value(notificationTime),
        notificationId: Value(notificationId),
      );

      final updatedRows = await (_database!.update(_database!.tasks)
            ..where((t) => t.id.equals(taskId)))
          .write(companion);

      return updatedRows > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Update task notification', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Update task notification'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  /// Update task priority
  Future<bool> updateTaskPriority(int taskId, TaskPriority priority) async {
    try {
      if (taskId <= 0) {
        throw AppException(
          message: 'Invalid task ID for priority update',
          type: ErrorType.validation,
        );
      }

      final companion = TasksCompanion(
        id: Value(taskId),
        priority: Value(priority.index),
      );

      final updatedRows = await (_database!.update(_database!.tasks)
            ..where((t) => t.id.equals(taskId)))
          .write(companion);

      return updatedRows > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Update task priority', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Update task priority'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  // ==================== ACHIEVEMENT OPERATIONS ====================
  
  /// Get all achievements
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final achievementDataList = await _database!.getAllAchievements();
      return achievementDataList.map((data) => _achievementDataToAchievement(data)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get all achievements', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get all achievements'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get earned achievements
  Future<List<Achievement>> getEarnedAchievements() async {
    try {
      final achievementDataList = await _database!.getEarnedAchievements();
      return achievementDataList.map((data) => _achievementDataToAchievement(data)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get earned achievements', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get earned achievements'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get unearned achievements
  Future<List<Achievement>> getUnearnedAchievements() async {
    try {
      final achievementDataList = await _database!.getUnearnedAchievements();
      return achievementDataList.map((data) => _achievementDataToAchievement(data)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get unearned achievements', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get unearned achievements'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get achievement by ID
  Future<Achievement?> getAchievementById(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw AppException(
          message: 'Achievement ID cannot be empty',
          type: ErrorType.validation,
        );
      }
      
      final achievementData = await _database!.getAchievementById(id);
      if (achievementData == null) return null;
      return _achievementDataToAchievement(achievementData);
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get achievement by ID', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get achievement by ID'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Update achievement progress
  Future<bool> updateAchievementProgress(String id, int progress) async {
    try {
      if (id.trim().isEmpty) {
        throw AppException(
          message: 'Achievement ID cannot be empty',
          type: ErrorType.validation,
        );
      }
      
      if (progress < 0) {
        throw AppException(
          message: 'Achievement progress cannot be negative',
          type: ErrorType.validation,
        );
      }
      
      final updatedRows = await _database!.updateAchievementProgress(id, progress);
      return updatedRows > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Update achievement progress', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Update achievement progress'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Mark achievement as earned
  Future<bool> earnAchievement(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw AppException(
          message: 'Achievement ID cannot be empty',
          type: ErrorType.validation,
        );
      }
      
      final updatedRows = await _database!.earnAchievement(id);
      return updatedRows > 0;
    } catch (e) {
      ErrorHandler.logError(e, context: 'Earn achievement', type: ErrorType.database);
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Earn achievement'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get achievements by type
  Future<List<Achievement>> getAchievementsByType(AchievementType type) async {
    try {
      final achievementDataList = await _database!.getAchievementsByType(type);
      return achievementDataList.map((data) => _achievementDataToAchievement(data)).toList();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get achievements by type', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get achievements by type'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get earned achievement count
  Future<int> getEarnedAchievementCount() async {
    try {
      return await _database!.getEarnedAchievementCount();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get earned achievement count', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get earned achievement count'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }
  
  /// Get total achievement count
  Future<int> getTotalAchievementCount() async {
    try {
      return await _database!.getTotalAchievementCount();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Get total achievement count', type: ErrorType.database);
      throw AppException(
        message: ErrorHandler.handleDatabaseError(e, context: 'Get total achievement count'),
        type: ErrorType.database,
        originalError: e,
      );
    }
  }

  /// Close the database connection
  Future<void> close() async {
    try {
      await _database?.close();
      _database = null;
      _instance = null; // Reset singleton instance for proper cleanup
    } catch (e) {
      ErrorHandler.logError(e, context: 'Close database', type: ErrorType.database);
    }
  }
  
  /// Convert TaskData (from Drift) to Task model
  Task _taskDataToTask(TaskData taskData) {
    return Task(
      id: taskData.id,
      title: taskData.title,
      description: taskData.description,
      isCompleted: taskData.isCompleted,
      isRoutine: taskData.isRoutine,
      createdAt: taskData.createdAt,
      completedAt: taskData.completedAt,
      routineTaskId: taskData.routineTaskId,
      taskDate: taskData.taskDate,
      priority: TaskPriority.values[taskData.priority],
      notificationTime: taskData.notificationTime,
      notificationId: taskData.notificationId,
    );
  }
  
  /// Convert AchievementData (from Drift) to Achievement model
  Achievement _achievementDataToAchievement(AchievementData achievementData) {
    return Achievement(
      id: achievementData.id,
      title: achievementData.title,
      description: achievementData.description,
      icon: IconData(achievementData.iconCodePoint, fontFamily: 'MaterialIcons'),
      type: achievementData.type,
      targetValue: achievementData.targetValue,
      isEarned: achievementData.isEarned,
      earnedAt: achievementData.earnedAt,
      currentProgress: achievementData.currentProgress,
    );
  }
}