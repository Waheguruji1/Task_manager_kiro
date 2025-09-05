import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/task_cleanup_service.dart';
import '../models/task.dart';
import '../models/achievement.dart';
import 'task_state_notifier.dart';
import 'user_state_notifier.dart';

/// Database Service Provider
/// 
/// Provides a singleton instance of DatabaseService
/// This provider is overridden after async initialization
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  // This will be overridden by the async initialization in main.dart
  // If accessed before initialization, it will throw an error
  throw StateError('DatabaseService not yet initialized. Use asyncDatabaseServiceProvider for initialization.');
});

/// Async Database Service Provider
/// 
/// Provides an asynchronously initialized DatabaseService instance
final asyncDatabaseServiceProvider = FutureProvider<DatabaseService>((ref) async {
  return await DatabaseService.getInstance();
});

/// Preferences Service Provider
/// 
/// Provides a singleton instance of PreferencesService
/// This provider is overridden after async initialization
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  // This will be overridden by the async initialization in main.dart
  // If accessed before initialization, it will throw an error
  throw StateError('PreferencesService not yet initialized. Use asyncPreferencesServiceProvider for initialization.');
});

/// Async Preferences Service Provider
/// 
/// Provides an asynchronously initialized PreferencesService instance
final asyncPreferencesServiceProvider = FutureProvider<PreferencesService>((ref) async {
  return await PreferencesService.getInstance();
});

/// Share Service Provider
/// 
/// Provides access to ShareService static methods
final shareServiceProvider = Provider<Type>((ref) {
  return ShareService;
});

/// User Name Provider
/// 
/// Provides the current user's name from SharedPreferences
final userNameProvider = FutureProvider<String?>((ref) async {
  final prefsService = await ref.watch(asyncPreferencesServiceProvider.future);
  return await prefsService.getUserName();
});

/// Has User Name Provider
/// 
/// Checks if a username exists in SharedPreferences
final hasUserNameProvider = FutureProvider<bool>((ref) async {
  final prefsService = await ref.watch(asyncPreferencesServiceProvider.future);
  return await prefsService.hasUserName();
});

/// First Launch Provider
/// 
/// Checks if this is the first launch of the app
final firstLaunchProvider = FutureProvider<bool>((ref) async {
  final prefsService = await ref.watch(asyncPreferencesServiceProvider.future);
  return await prefsService.isFirstLaunch();
});

/// All Tasks Provider
/// 
/// Provides a list of all tasks from the database
final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  return await dbService.getAllTasks();
});

/// Everyday Tasks Provider
/// 
/// Provides a list of everyday tasks (includes regular tasks and daily routine instances)
/// Tasks are automatically sorted by priority (High → Medium → No Priority)
final everydayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  final tasks = await dbService.getEverydayTasks();
  return Task.sortByPriority(tasks);
});

/// Routine Tasks Provider
/// 
/// Provides a list of routine tasks
/// Tasks are automatically sorted by priority (High → Medium → No Priority)
final routineTasksProvider = FutureProvider<List<Task>>((ref) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  final tasks = await dbService.getRoutineTasks();
  return Task.sortByPriority(tasks);
});

/// Task by ID Provider
/// 
/// Provides a specific task by its ID
final taskByIdProvider = FutureProvider.family<Task?, int>((ref, id) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  return await dbService.getTaskById(id);
});

/// Task State Notifier Provider
/// 
/// Provides a StateNotifier for managing task state and operations
/// This is the main provider that should be used for real-time task state updates
final taskStateNotifierProvider = StateNotifierProvider<TaskStateNotifier, TaskState>((ref) {
  // This will be overridden by the async initialization
  throw StateError('TaskStateNotifier not yet initialized. Use asyncTaskStateNotifierProvider for initialization.');
});

/// Async Task State Notifier Provider
/// 
/// Provides an asynchronously initialized TaskStateNotifier
final asyncTaskStateNotifierProvider = FutureProvider<TaskStateNotifier>((ref) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  final achievementService = await ref.watch(achievementServiceProvider.future);
  final notificationService = ref.watch(notificationServiceProvider);
  final taskStateNotifier = TaskStateNotifier(dbService, achievementService, notificationService);
  
  // Connect with task change notifier for stats updates
  final taskChangeNotifier = ref.read(taskChangeNotifierProvider.notifier);
  taskStateNotifier.setTaskChangeCallback(() => taskChangeNotifier.notifyTasksChanged());
  
  return taskStateNotifier;
});

/// Initialized Task State Notifier Provider
/// 
/// Provides a StateNotifier that can be watched for real-time updates
/// This is initialized asynchronously and then provides real-time state updates
final initializedTaskStateNotifierProvider = StateNotifierProvider<TaskStateNotifier, TaskState>((ref) {
  // This will be overridden when the async initialization completes
  throw StateError('TaskStateNotifier not yet initialized. Use asyncTaskStateNotifierProvider for initialization.');
});

/// Task State Stream Provider
/// 
/// Provides a stream of task state changes for real-time UI updates
/// Now uses proper StateNotifier watching instead of polling
final taskStateStreamProvider = StreamProvider<TaskState>((ref) async* {
  final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
  
  // Emit initial state
  yield taskStateNotifier.currentState;
  
  // Watch for state changes using StateNotifier's stream
  await for (final state in taskStateNotifier.stream) {
    yield state;
  }
});

/// Task State Provider
/// 
/// Provides real-time access to task state for UI consumption
/// This is what the UI should watch for immediate state updates
final taskStateProvider = FutureProvider<TaskState>((ref) async {
  final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
  return taskStateNotifier.currentState;
});

/// Real-time Everyday Tasks Provider
/// 
/// Provides real-time access to everyday tasks from TaskStateNotifier
final realtimeEverydayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
  return taskStateNotifier.currentState.everydayTasks;
});

/// Real-time Routine Tasks Provider
/// 
/// Provides real-time access to routine tasks from TaskStateNotifier
final realtimeRoutineTasksProvider = FutureProvider<List<Task>>((ref) async {
  final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
  return taskStateNotifier.currentState.routineTasks;
});

/// User State Notifier Provider
/// 
/// Provides a StateNotifier for managing user authentication state and operations
final userStateNotifierProvider = StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  throw StateError('UserStateNotifier not yet initialized. Use asyncUserStateNotifierProvider for initialization.');
});

/// Async User State Notifier Provider
/// 
/// Provides an asynchronously initialized UserStateNotifier
final asyncUserStateNotifierProvider = FutureProvider<UserStateNotifier>((ref) async {
  final prefsService = await ref.watch(asyncPreferencesServiceProvider.future);
  return UserStateNotifier(prefsService);
});

/// Stats Service Provider
/// 
/// Provides a singleton instance of StatsService
final statsServiceProvider = Provider<StatsService>((ref) {
  return StatsService();
});

/// Achievement Service Provider
/// 
/// Provides an asynchronously initialized AchievementService instance
final achievementServiceProvider = FutureProvider<AchievementService>((ref) async {
  return await AchievementService.getInstance();
});

/// All Achievements Provider
/// 
/// Provides a list of all achievements from the database
/// Uses autoDispose to prevent memory leaks and avoid circular dependencies
final allAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  return await achievementService.getAllAchievements();
});

/// Earned Achievements Provider
/// 
/// Provides a list of earned achievements
/// Uses autoDispose to prevent memory leaks and avoid circular dependencies
final earnedAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  return await achievementService.getEarnedAchievements();
});

/// Unearned Achievements Provider
/// 
/// Provides a list of unearned achievements with progress
/// Uses autoDispose to prevent memory leaks and avoid circular dependencies
final unearnedAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  return await achievementService.getUnearnedAchievements();
});

/// Achievement Refresh Trigger Provider
/// 
/// Simple state provider to trigger achievement refreshes manually
/// This avoids circular dependencies while allowing manual refresh
final achievementRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// Completion Heatmap Data Provider
/// 
/// Provides heatmap data for task completion activity
/// This provider automatically refreshes when task state changes
final completionHeatmapDataProvider = FutureProvider.autoDispose<Map<DateTime, int>>((ref) async {
  final statsService = ref.watch(statsServiceProvider);
  
  // Watch the task change notifier to ensure this provider refreshes
  ref.watch(taskChangeNotifierProvider);
  
  // Watch the task state notifier to get real-time updates
  try {
    final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
    final taskState = taskStateNotifier.currentState;
    final allTasks = [...taskState.everydayTasks, ...taskState.routineTasks];
    return statsService.calculateCompletionHeatmapData(allTasks);
  } catch (e) {
    // Fallback to regular provider if task state notifier is not available
    final tasks = await ref.watch(allTasksProvider.future);
    return statsService.calculateCompletionHeatmapData(tasks);
  }
});

/// Creation vs Completion Heatmap Data Provider
/// 
/// Provides heatmap data for task creation vs completion
/// This provider automatically refreshes when task state changes
final creationCompletionHeatmapDataProvider = FutureProvider.autoDispose<Map<DateTime, Map<String, int>>>((ref) async {
  final statsService = ref.watch(statsServiceProvider);
  
  // Watch the task change notifier to ensure this provider refreshes
  ref.watch(taskChangeNotifierProvider);
  
  // Watch the task state notifier to get real-time updates
  try {
    final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
    final taskState = taskStateNotifier.currentState;
    final allTasks = [...taskState.everydayTasks, ...taskState.routineTasks];
    return statsService.calculateCreationCompletionHeatmapData(allTasks);
  } catch (e) {
    // Fallback to regular provider if task state notifier is not available
    final tasks = await ref.watch(allTasksProvider.future);
    return statsService.calculateCreationCompletionHeatmapData(tasks);
  }
});

/// Real-time Stats Provider
/// 
/// Provides real-time statistics that update when tasks change
final realtimeStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final statsService = ref.watch(statsServiceProvider);
  
  // Watch the task change notifier to ensure this provider refreshes
  ref.watch(taskChangeNotifierProvider);
  
  try {
    final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
    final taskState = taskStateNotifier.currentState;
    final allTasks = [...taskState.everydayTasks, ...taskState.routineTasks];
    return statsService.calculateOverallStats(allTasks);
  } catch (e) {
    // Fallback to regular provider if task state notifier is not available
    final tasks = await ref.watch(allTasksProvider.future);
    return statsService.calculateOverallStats(tasks);
  }
});

/// Task Change Notifier Provider
/// 
/// This provider watches for task state changes and invalidates stats providers
final taskChangeNotifierProvider = StateNotifierProvider<TaskChangeNotifier, int>((ref) {
  return TaskChangeNotifier(ref);
});

/// Task Change Notifier Class
/// 
/// Monitors task state changes and invalidates dependent providers
/// Now uses proper reactive approach instead of polling
class TaskChangeNotifier extends StateNotifier<int> {
  final Ref _ref;
  
  TaskChangeNotifier(this._ref) : super(0);
  
  /// Notify that tasks have changed
  /// This should be called by TaskStateNotifier when tasks are modified
  void notifyTasksChanged() {
    // Invalidate stats providers to trigger refresh
    _ref.invalidate(completionHeatmapDataProvider);
    _ref.invalidate(creationCompletionHeatmapDataProvider);
    _ref.invalidate(realtimeStatsProvider);
    
    // Update state to notify listeners
    state = state + 1;
  }
}

/// Notification Service Provider
/// 
/// Provides a singleton instance of NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Permission Service Provider
/// 
/// Provides a singleton instance of PermissionService
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// Notifications Enabled Provider
/// 
/// Provides the current notification enabled status from SharedPreferences
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final prefsService = await ref.watch(asyncPreferencesServiceProvider.future);
  return await prefsService.areNotificationsEnabled();
});

/// Notification Permission Status Provider
/// 
/// Provides the current notification permission status from the system
final notificationPermissionStatusProvider = FutureProvider<bool>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.areNotificationsEnabled();
});

/// Auto-Delete Enabled Provider
/// 
/// Provides the current auto-delete enabled status from SharedPreferences
final autoDeleteEnabledProvider = FutureProvider<bool>((ref) async {
  final prefsService = await ref.watch(asyncPreferencesServiceProvider.future);
  return await prefsService.isAutoDeleteEnabled();
});

/// Task Cleanup Service Provider
/// 
/// Provides a singleton instance of TaskCleanupService
final taskCleanupServiceProvider = Provider<TaskCleanupService>((ref) {
  return TaskCleanupService();
});

/// Cleanup Statistics Provider
/// 
/// Provides cleanup statistics for monitoring purposes
final cleanupStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final cleanupService = ref.watch(taskCleanupServiceProvider);
  final tasks = await ref.watch(allTasksProvider.future);
  return cleanupService.getCleanupStatistics(tasks);
});

/// Perform Cleanup Provider
/// 
/// Performs automatic cleanup of old completed tasks
final performCleanupProvider = FutureProvider<bool>((ref) async {
  final cleanupService = ref.watch(taskCleanupServiceProvider);
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  final isAutoDeleteEnabled = await ref.watch(autoDeleteEnabledProvider.future);
  return await cleanupService.performCleanupIfNeeded(
    dbService, 
    isAutoDeleteEnabled: isAutoDeleteEnabled,
  );
});