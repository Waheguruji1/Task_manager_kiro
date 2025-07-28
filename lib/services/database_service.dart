import 'package:drift/drift.dart';
import '../models/database.dart';
import '../models/task.dart';
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
    );
  }
}