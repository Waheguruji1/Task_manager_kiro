import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

/// Task State
/// 
/// Represents the current state of tasks in the app
class TaskState {
  final List<Task> everydayTasks;
  final List<Task> routineTasks;
  final bool isLoading;
  final String? error;

  const TaskState({
    this.everydayTasks = const [],
    this.routineTasks = const [],
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<Task>? everydayTasks,
    List<Task>? routineTasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      everydayTasks: everydayTasks ?? this.everydayTasks,
      routineTasks: routineTasks ?? this.routineTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Task State Notifier
/// 
/// Manages the state of tasks and provides methods for task operations
class TaskStateNotifier extends StateNotifier<TaskState> {
  final DatabaseService _databaseService;

  TaskStateNotifier(this._databaseService) : super(const TaskState()) {
    loadTasks();
  }

  /// Load all tasks from the database
  Future<void> loadTasks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final everydayTasks = await _databaseService.getEverydayTasks();
      final routineTasks = await _databaseService.getRoutineTasks();
      
      state = state.copyWith(
        everydayTasks: everydayTasks,
        routineTasks: routineTasks,
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
      
      final taskId = await _databaseService.createTask(task);
      
      if (taskId > 0) {
        // Reload tasks to get the updated list
        await loadTasks();
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
      
      final success = await _databaseService.updateTask(task);
      
      if (success) {
        // Reload tasks to get the updated list
        await loadTasks();
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
      
      final success = await _databaseService.deleteTask(taskId);
      
      if (success) {
        // Reload tasks to get the updated list
        await loadTasks();
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
      
      final success = await _databaseService.toggleTaskCompletion(taskId);
      
      if (success) {
        // Reload tasks to get the updated list
        await loadTasks();
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
}