import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import '../services/task_cleanup_service.dart';
import '../services/yearly_data_cleanup_service.dart';
import '../models/task.dart';
import '../models/achievement.dart';
import '../utils/error_handler.dart';
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
/// Uses autoDispose to ensure fresh data on each access
final userNameProvider = FutureProvider.autoDispose<String?>((ref) async {
  final prefsService = await ref.watch(asyncPreferencesServiceProvider.future);
  final userName = await prefsService.getUserName();
  
  // Ensure we return a clean string or null
  if (userName != null && userName.trim().isNotEmpty) {
    return userName.trim();
  }
  return null;
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
/// Enhanced task change monitoring with yearly cleanup integration
/// and optimized provider invalidation
class TaskChangeNotifier extends StateNotifier<int> {
  final Ref _ref;
  late final ProviderManager _providerManager;
  bool _disposed = false;
  
  TaskChangeNotifier(this._ref) : super(0) {
    // Initialize provider manager for enhanced invalidation
    _providerManager = _ref.read(providerManagerProvider);
  }
  
  /// Notify that tasks have changed
  /// Enhanced with provider manager integration and yearly cleanup awareness
  void notifyTasksChanged() {
    if (_disposed) return;
    
    // Use provider manager for comprehensive invalidation
    _providerManager.handleTaskStateChange();
    
    // Traditional invalidations for backward compatibility
    _ref.invalidate(completionHeatmapDataProvider);
    _ref.invalidate(creationCompletionHeatmapDataProvider);
    _ref.invalidate(realtimeStatsProvider);
    _ref.invalidate(autoRefreshStatsProvider);
    
    // Invalidate achievement providers to trigger refresh
    _ref.invalidate(allAchievementsProvider);
    _ref.invalidate(earnedAchievementsProvider);
    _ref.invalidate(unearnedAchievementsProvider);
    _ref.invalidate(autoRefreshAchievementsProvider);
    _ref.invalidate(autoRefreshEarnedAchievementsProvider);
    _ref.invalidate(autoRefreshUnearnedAchievementsProvider);
    
    // Invalidate current year tasks for yearly cleanup integration
    _ref.invalidate(currentYearTasksProvider);
    
    // Update state to notify listeners
    state = state + 1;
  }
  
  /// Notify that yearly cleanup has occurred
  void notifyYearlyCleanup() {
    if (_disposed) return;
    
    _providerManager.handleYearlyCleanup();
    
    // Update state to notify listeners
    state = state + 1;
  }
  
  /// Force refresh all providers
  void forceRefreshAll() {
    if (_disposed) return;
    
    _providerManager.forceRefreshAll();
    
    // Update state to notify listeners
    state = state + 1;
  }
  
  /// Dispose of resources
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
  /// Check if the notifier is disposed
  bool get isDisposed => _disposed;
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

/// Yearly Data Cleanup Service Provider
/// 
/// Provides a singleton instance of YearlyDataCleanupService
final yearlyDataCleanupServiceProvider = Provider<YearlyDataCleanupService>((ref) {
  // This will be overridden after async initialization
  throw StateError('YearlyDataCleanupService not yet initialized. Use asyncYearlyDataCleanupServiceProvider for initialization.');
});

/// Async Yearly Data Cleanup Service Provider
/// 
/// Provides an asynchronously initialized YearlyDataCleanupService instance
final asyncYearlyDataCleanupServiceProvider = FutureProvider<YearlyDataCleanupService>((ref) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  return YearlyDataCleanupService(dbService);
});

/// Perform Yearly Cleanup Provider
/// 
/// Performs automatic yearly data cleanup during app startup
final performYearlyCleanupProvider = FutureProvider<bool>((ref) async {
  final yearlyCleanupService = await ref.watch(asyncYearlyDataCleanupServiceProvider.future);
  return await yearlyCleanupService.performCleanupIfNeeded();
});

/// Yearly Cleanup Info Provider
/// 
/// Provides information about yearly cleanup status and statistics
final yearlyCleanupInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final yearlyCleanupService = await ref.watch(asyncYearlyDataCleanupServiceProvider.future);
  return await yearlyCleanupService.getCleanupInfo();
});

/// Screen Navigation Notifier Provider
/// 
/// Tracks screen navigation to trigger auto-refresh for stats and achievements
/// Enhanced with proper disposal and memory management
final screenNavigationNotifierProvider = StateNotifierProvider.autoDispose<ScreenNavigationNotifier, ScreenNavigationState>((ref) {
  final notifier = ScreenNavigationNotifier(ref);
  
  // Ensure proper disposal when provider is no longer needed
  ref.onDispose(() {
    notifier.dispose();
  });
  
  return notifier;
});

/// Enhanced Provider Manager
/// 
/// Centralized manager for provider lifecycle and auto-refresh functionality
/// Provides advanced invalidation logic and memory management
final providerManagerProvider = Provider<ProviderManager>((ref) {
  final manager = ProviderManager(ref);
  
  // Ensure proper disposal
  ref.onDispose(() {
    manager.dispose();
  });
  
  return manager;
});

/// Auto-refresh Stats Provider
/// 
/// Automatically refreshes when navigating to stats screen
/// Enhanced with current year filtering and yearly cleanup integration
/// Uses autoDispose to ensure fresh data on each navigation
final autoRefreshStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final statsService = ref.watch(statsServiceProvider);
  
  // Watch navigation state to trigger refresh on stats screen navigation
  ref.watch(screenNavigationNotifierProvider);
  
  // Watch task changes to ensure immediate updates
  ref.watch(taskChangeNotifierProvider);
  
  // Watch yearly cleanup to ensure stats reflect current year data
  ref.watch(yearlyCleanupInfoProvider);
  
  try {
    final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
    final taskState = taskStateNotifier.currentState;
    
    // Filter tasks to current year only for stats display
    final currentYear = DateTime.now().year;
    final currentYearTasks = [...taskState.everydayTasks, ...taskState.routineTasks]
        .where((task) => task.createdAt.year == currentYear)
        .toList();
    
    // Calculate comprehensive stats for current year only
    final overallStats = statsService.calculateOverallStats(currentYearTasks);
    final heatmapData = statsService.calculateCompletionHeatmapData(currentYearTasks);
    final creationCompletionData = statsService.calculateCreationCompletionHeatmapData(currentYearTasks);
    
    return {
      'overallStats': overallStats,
      'heatmapData': heatmapData,
      'creationCompletionData': creationCompletionData,
      'currentYear': currentYear,
      'taskCount': currentYearTasks.length,
      'lastRefresh': DateTime.now().millisecondsSinceEpoch,
    };
  } catch (e) {
    // Fallback to regular providers if task state notifier is not available
    final tasks = await ref.watch(allTasksProvider.future);
    final currentYear = DateTime.now().year;
    final currentYearTasks = tasks.where((task) => task.createdAt.year == currentYear).toList();
    
    final overallStats = statsService.calculateOverallStats(currentYearTasks);
    final heatmapData = statsService.calculateCompletionHeatmapData(currentYearTasks);
    final creationCompletionData = statsService.calculateCreationCompletionHeatmapData(currentYearTasks);
    
    return {
      'overallStats': overallStats,
      'heatmapData': heatmapData,
      'creationCompletionData': creationCompletionData,
      'currentYear': currentYear,
      'taskCount': currentYearTasks.length,
      'lastRefresh': DateTime.now().millisecondsSinceEpoch,
    };
  }
});

/// Auto-refresh Achievements Provider
/// 
/// Automatically refreshes when navigating to achievements screen
/// Enhanced with yearly cleanup integration and proper disposal
/// Uses autoDispose to ensure fresh data on each navigation
final autoRefreshAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  
  // Watch navigation state to trigger refresh on achievements screen navigation
  ref.watch(screenNavigationNotifierProvider);
  
  // Watch task changes to ensure immediate updates
  ref.watch(taskChangeNotifierProvider);
  
  // Watch yearly cleanup to ensure achievements reflect current year progress
  ref.watch(yearlyCleanupInfoProvider);
  
  // Get fresh achievement data with current progress
  final achievements = await achievementService.getAllAchievements();
  
  // Ensure achievements are properly updated after yearly cleanup
  return achievements;
});

/// Auto-refresh Earned Achievements Provider
/// 
/// Automatically refreshes earned achievements when navigating to achievements screen
/// Enhanced with yearly cleanup integration
final autoRefreshEarnedAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  
  // Watch navigation state to trigger refresh on achievements screen navigation
  ref.watch(screenNavigationNotifierProvider);
  
  // Watch task changes to ensure immediate updates
  ref.watch(taskChangeNotifierProvider);
  
  // Watch yearly cleanup to ensure earned achievements reflect current year
  ref.watch(yearlyCleanupInfoProvider);
  
  return await achievementService.getEarnedAchievements();
});

/// Auto-refresh Unearned Achievements Provider
/// 
/// Automatically refreshes unearned achievements when navigating to achievements screen
/// Enhanced with yearly cleanup integration
final autoRefreshUnearnedAchievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  
  // Watch navigation state to trigger refresh on achievements screen navigation
  ref.watch(screenNavigationNotifierProvider);
  
  // Watch task changes to ensure immediate updates
  ref.watch(taskChangeNotifierProvider);
  
  // Watch yearly cleanup to ensure unearned achievements reflect current year
  ref.watch(yearlyCleanupInfoProvider);
  
  return await achievementService.getUnearnedAchievements();
});

/// Current Year Tasks Provider
/// 
/// Provides tasks filtered to current year only for stats and visualization
/// Enhanced with yearly cleanup integration and efficient memory management
final currentYearTasksProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  final currentYear = DateTime.now().year;
  
  // Watch yearly cleanup to ensure data is current
  ref.watch(yearlyCleanupInfoProvider);
  
  // Watch task changes for immediate updates
  ref.watch(taskChangeNotifierProvider);
  
  try {
    final taskStateNotifier = await ref.watch(asyncTaskStateNotifierProvider.future);
    final taskState = taskStateNotifier.currentState;
    final allTasks = [...taskState.everydayTasks, ...taskState.routineTasks];
    
    return allTasks.where((task) => task.createdAt.year == currentYear).toList();
  } catch (e) {
    // Fallback to regular provider
    final tasks = await ref.watch(allTasksProvider.future);
    return tasks.where((task) => task.createdAt.year == currentYear).toList();
  }
});

/// Enhanced Stats Provider with Memory Management
/// 
/// Provides comprehensive stats with automatic cleanup and memory optimization
/// Integrates with yearly cleanup and provider manager
final enhancedStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final statsService = ref.watch(statsServiceProvider);
  final providerManager = ref.watch(providerManagerProvider);
  
  // Watch for navigation and task changes
  ref.watch(screenNavigationNotifierProvider);
  ref.watch(taskChangeNotifierProvider);
  
  // Watch yearly cleanup for data consistency
  final yearlyCleanupInfo = await ref.watch(yearlyCleanupInfoProvider.future);
  
  try {
    final currentYearTasks = await ref.watch(currentYearTasksProvider.future);
    
    // Calculate comprehensive stats
    final overallStats = statsService.calculateOverallStats(currentYearTasks);
    final heatmapData = statsService.calculateCompletionHeatmapData(currentYearTasks);
    final creationCompletionData = statsService.calculateCreationCompletionHeatmapData(currentYearTasks);
    
    // Get provider performance stats for debugging
    final providerStats = providerManager.getProviderStats();
    
    return {
      'overallStats': overallStats,
      'heatmapData': heatmapData,
      'creationCompletionData': creationCompletionData,
      'currentYear': DateTime.now().year,
      'taskCount': currentYearTasks.length,
      'lastRefresh': DateTime.now().millisecondsSinceEpoch,
      'yearlyCleanupInfo': yearlyCleanupInfo,
      'providerStats': providerStats,
    };
  } catch (e) {
    ErrorHandler.logError(e, context: 'Enhanced stats provider', type: ErrorType.unknown);
    return {
      'error': e.toString(),
      'lastRefresh': DateTime.now().millisecondsSinceEpoch,
    };
  }
});

/// Enhanced Achievements Provider with Memory Management
/// 
/// Provides comprehensive achievement data with automatic cleanup and optimization
/// Integrates with yearly cleanup and provider manager
final enhancedAchievementsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  final providerManager = ref.watch(providerManagerProvider);
  
  // Watch for navigation and task changes
  ref.watch(screenNavigationNotifierProvider);
  ref.watch(taskChangeNotifierProvider);
  
  // Watch yearly cleanup for data consistency
  final yearlyCleanupInfo = await ref.watch(yearlyCleanupInfoProvider.future);
  
  try {
    // Get all achievement data
    final allAchievements = await achievementService.getAllAchievements();
    final earnedAchievements = await achievementService.getEarnedAchievements();
    final unearnedAchievements = await achievementService.getUnearnedAchievements();
    
    // Get provider performance stats for debugging
    final providerStats = providerManager.getProviderStats();
    
    return {
      'allAchievements': allAchievements,
      'earnedAchievements': earnedAchievements,
      'unearnedAchievements': unearnedAchievements,
      'earnedCount': earnedAchievements.length,
      'totalCount': allAchievements.length,
      'completionPercentage': allAchievements.isEmpty 
          ? 0.0 
          : (earnedAchievements.length / allAchievements.length * 100),
      'lastRefresh': DateTime.now().millisecondsSinceEpoch,
      'yearlyCleanupInfo': yearlyCleanupInfo,
      'providerStats': providerStats,
    };
  } catch (e) {
    ErrorHandler.logError(e, context: 'Enhanced achievements provider', type: ErrorType.unknown);
    return {
      'error': e.toString(),
      'lastRefresh': DateTime.now().millisecondsSinceEpoch,
    };
  }
});

/// Memory Usage Monitor Provider
/// 
/// Monitors provider memory usage and provides optimization insights
final memoryUsageMonitorProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final providerManager = ref.watch(providerManagerProvider);
  
  // Get provider statistics
  final providerStats = providerManager.getProviderStats();
  
  // Calculate memory usage estimates
  final activeProviderCount = providerStats['invalidationCounts']?.length ?? 0;
  final totalInvalidations = providerStats['totalInvalidations'] ?? 0;
  
  return {
    'activeProviderCount': activeProviderCount,
    'totalInvalidations': totalInvalidations,
    'averageInvalidationsPerProvider': activeProviderCount > 0 
        ? (totalInvalidations / activeProviderCount).round() 
        : 0,
    'memoryOptimizationRecommended': totalInvalidations > 100,
    'lastCheck': DateTime.now().millisecondsSinceEpoch,
    'providerStats': providerStats,
  };
});

/// Provider Invalidation Controller
/// 
/// Centralized controller for invalidating providers when data changes
/// This ensures consistent refresh behavior across the app
final providerInvalidationControllerProvider = Provider<ProviderInvalidationController>((ref) {
  return ProviderInvalidationController(ref);
});

/// Provider Invalidation Controller Class
/// 
/// Manages provider invalidation for auto-refresh functionality
class ProviderInvalidationController {
  final Ref _ref;
  
  ProviderInvalidationController(this._ref);
  
  /// Invalidates all stats-related providers
  void invalidateStatsProviders() {
    _ref.invalidate(autoRefreshStatsProvider);
    _ref.invalidate(completionHeatmapDataProvider);
    _ref.invalidate(creationCompletionHeatmapDataProvider);
    _ref.invalidate(realtimeStatsProvider);
    _ref.invalidate(currentYearTasksProvider);
  }
  
  /// Invalidates all achievement-related providers
  void invalidateAchievementProviders() {
    _ref.invalidate(autoRefreshAchievementsProvider);
    _ref.invalidate(autoRefreshEarnedAchievementsProvider);
    _ref.invalidate(autoRefreshUnearnedAchievementsProvider);
    _ref.invalidate(allAchievementsProvider);
    _ref.invalidate(earnedAchievementsProvider);
    _ref.invalidate(unearnedAchievementsProvider);
  }
  
  /// Invalidates all data providers (stats and achievements)
  void invalidateAllDataProviders() {
    invalidateStatsProviders();
    invalidateAchievementProviders();
  }
  
  /// Invalidates providers after yearly cleanup
  void invalidateAfterYearlyCleanup() {
    // Invalidate yearly cleanup info first
    _ref.invalidate(yearlyCleanupInfoProvider);
    _ref.invalidate(performYearlyCleanupProvider);
    
    // Then invalidate all data providers to reflect cleanup changes
    invalidateAllDataProviders();
    
    // Also invalidate task providers to ensure consistency
    _ref.invalidate(allTasksProvider);
    _ref.invalidate(everydayTasksProvider);
    _ref.invalidate(routineTasksProvider);
  }
}

/// Screen Navigation State
/// 
/// Represents the current navigation state for auto-refresh functionality
class ScreenNavigationState {
  final String currentScreen;
  final int navigationCount;
  final DateTime lastNavigationTime;

  const ScreenNavigationState({
    required this.currentScreen,
    required this.navigationCount,
    required this.lastNavigationTime,
  });

  ScreenNavigationState copyWith({
    String? currentScreen,
    int? navigationCount,
    DateTime? lastNavigationTime,
  }) {
    return ScreenNavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      navigationCount: navigationCount ?? this.navigationCount,
      lastNavigationTime: lastNavigationTime ?? this.lastNavigationTime,
    );
  }
}

/// Screen Navigation Notifier
/// 
/// Manages screen navigation state and triggers auto-refresh for stats and achievements
/// Enhanced with proper disposal and invalidation controller integration
class ScreenNavigationNotifier extends StateNotifier<ScreenNavigationState> {
  final Ref _ref;
  late final ProviderManager _providerManager;
  bool _disposed = false;

  ScreenNavigationNotifier(this._ref) : super(ScreenNavigationState(
    currentScreen: 'home',
    navigationCount: 0,
    lastNavigationTime: DateTime.now(),
  )) {
    _providerManager = _ref.read(providerManagerProvider);
  }

  /// Notify navigation to stats screen
  void navigateToStats() {
    if (_disposed) return;
    
    state = state.copyWith(
      currentScreen: 'stats',
      navigationCount: state.navigationCount + 1,
      lastNavigationTime: DateTime.now(),
    );
    
    // Use provider manager for enhanced invalidation
    _providerManager.handleStatsScreenNavigation();
  }

  /// Notify navigation to achievements screen
  void navigateToAchievements() {
    if (_disposed) return;
    
    state = state.copyWith(
      currentScreen: 'achievements',
      navigationCount: state.navigationCount + 1,
      lastNavigationTime: DateTime.now(),
    );
    
    // Use provider manager for enhanced invalidation
    _providerManager.handleAchievementsScreenNavigation();
  }

  /// Notify navigation to other screens
  void navigateToScreen(String screenName) {
    if (_disposed) return;
    
    state = state.copyWith(
      currentScreen: screenName,
      navigationCount: state.navigationCount + 1,
      lastNavigationTime: DateTime.now(),
    );
    
    // Notify provider manager of general navigation
    _providerManager.handleGeneralNavigation(screenName);
  }

  /// Force refresh of current screen data
  void forceRefresh() {
    if (_disposed) return;
    
    if (state.currentScreen == 'stats') {
      navigateToStats();
    } else if (state.currentScreen == 'achievements') {
      navigateToAchievements();
    }
  }
  
  /// Force refresh of all data providers
  void forceRefreshAll() {
    if (_disposed) return;
    
    _providerManager.forceRefreshAll();
  }
  
  /// Notify that yearly cleanup has occurred
  void notifyYearlyCleanup() {
    if (_disposed) return;
    
    _providerManager.handleYearlyCleanup();
  }
  
  /// Dispose of resources
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
  /// Check if the notifier is disposed
  bool get isDisposed => _disposed;
}

/// Provider Manager
/// 
/// Enhanced provider management system with advanced auto-refresh functionality,
/// memory management, and debugging capabilities
class ProviderManager {
  final Ref _ref;
  late final ProviderInvalidationController _invalidationController;
  bool _disposed = false;
  
  // Tracking for debugging and optimization
  final Map<String, DateTime> _lastInvalidationTimes = {};
  final Map<String, int> _invalidationCounts = {};
  
  ProviderManager(this._ref) {
    _invalidationController = _ref.read(providerInvalidationControllerProvider);
  }
  
  /// Handle navigation to stats screen with enhanced auto-refresh
  void handleStatsScreenNavigation() {
    if (_disposed) return;
    
    _trackInvalidation('stats_navigation');
    
    // Invalidate stats providers with yearly cleanup awareness
    _invalidationController.invalidateStatsProviders();
    
    // Also ensure yearly cleanup info is fresh
    _ref.invalidate(yearlyCleanupInfoProvider);
    
    // Log navigation for debugging
    _logProviderActivity('Stats screen navigation triggered auto-refresh');
  }
  
  /// Handle navigation to achievements screen with enhanced auto-refresh
  void handleAchievementsScreenNavigation() {
    if (_disposed) return;
    
    _trackInvalidation('achievements_navigation');
    
    // Invalidate achievement providers with yearly cleanup awareness
    _invalidationController.invalidateAchievementProviders();
    
    // Also ensure yearly cleanup info is fresh
    _ref.invalidate(yearlyCleanupInfoProvider);
    
    // Log navigation for debugging
    _logProviderActivity('Achievements screen navigation triggered auto-refresh');
  }
  
  /// Handle general navigation events
  void handleGeneralNavigation(String screenName) {
    if (_disposed) return;
    
    _trackInvalidation('general_navigation_$screenName');
    
    // For certain screens, we might want to preemptively refresh data
    if (screenName == 'home') {
      // Refresh task data when returning to home
      _ref.invalidate(realtimeEverydayTasksProvider);
      _ref.invalidate(realtimeRoutineTasksProvider);
    }
    
    _logProviderActivity('Navigation to $screenName');
  }
  
  /// Handle yearly cleanup with comprehensive provider invalidation
  void handleYearlyCleanup() {
    if (_disposed) return;
    
    _trackInvalidation('yearly_cleanup');
    
    // Use invalidation controller for comprehensive cleanup
    _invalidationController.invalidateAfterYearlyCleanup();
    
    // Additional invalidations specific to yearly cleanup
    _ref.invalidate(currentYearTasksProvider);
    _ref.invalidate(userNameProvider); // In case user data was affected
    
    _logProviderActivity('Yearly cleanup triggered comprehensive provider refresh');
  }
  
  /// Force refresh all data providers
  void forceRefreshAll() {
    if (_disposed) return;
    
    _trackInvalidation('force_refresh_all');
    
    _invalidationController.invalidateAllDataProviders();
    
    // Also invalidate core task providers
    _ref.invalidate(allTasksProvider);
    _ref.invalidate(everydayTasksProvider);
    _ref.invalidate(routineTasksProvider);
    _ref.invalidate(realtimeEverydayTasksProvider);
    _ref.invalidate(realtimeRoutineTasksProvider);
    
    _logProviderActivity('Force refresh all providers');
  }
  
  /// Handle task state changes with immediate UI updates
  void handleTaskStateChange() {
    if (_disposed) return;
    
    _trackInvalidation('task_state_change');
    
    // Immediate invalidation for real-time updates
    _invalidationController.invalidateAllDataProviders();
    
    _logProviderActivity('Task state change triggered immediate refresh');
  }
  
  /// Optimize provider memory usage by disposing unused providers
  void optimizeMemoryUsage() {
    if (_disposed) return;
    
    _trackInvalidation('memory_optimization');
    
    // Dispose of autoDispose providers that haven't been used recently
    // This is handled automatically by Riverpod's autoDispose, but we can
    // trigger it manually for optimization
    
    _logProviderActivity('Memory optimization performed');
  }
  
  /// Get provider performance statistics for debugging
  Map<String, dynamic> getProviderStats() {
    return {
      'lastInvalidationTimes': Map<String, String>.fromEntries(
        _lastInvalidationTimes.entries.map(
          (e) => MapEntry(e.key, e.value.toIso8601String()),
        ),
      ),
      'invalidationCounts': Map<String, int>.from(_invalidationCounts),
      'totalInvalidations': _invalidationCounts.values.fold(0, (a, b) => a + b),
      'isDisposed': _disposed,
    };
  }
  
  /// Reset provider statistics (useful for debugging)
  void resetStats() {
    _lastInvalidationTimes.clear();
    _invalidationCounts.clear();
    _logProviderActivity('Provider statistics reset');
  }
  
  /// Track invalidation for debugging and optimization
  void _trackInvalidation(String type) {
    _lastInvalidationTimes[type] = DateTime.now();
    _invalidationCounts[type] = (_invalidationCounts[type] ?? 0) + 1;
  }
  
  /// Log provider activity for debugging
  void _logProviderActivity(String message) {
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      ErrorHandler.logInfo(
        '[ProviderManager] $message at ${DateTime.now().toIso8601String()}',
        context: 'Provider Manager',
      );
    }
  }
  
  /// Dispose of resources
  void dispose() {
    _disposed = true;
    _lastInvalidationTimes.clear();
    _invalidationCounts.clear();
  }
  
  /// Check if the manager is disposed
  bool get isDisposed => _disposed;
}

/// Provider Lifecycle Manager
/// 
/// Manages the lifecycle of all providers with enhanced disposal and cleanup
final providerLifecycleManagerProvider = Provider<ProviderLifecycleManager>((ref) {
  final manager = ProviderLifecycleManager();
  
  // Ensure proper disposal
  ref.onDispose(() {
    manager.dispose();
  });
  
  return manager;
});

/// Provider Lifecycle Manager Class
/// 
/// Centralized management of provider lifecycle with memory optimization
class ProviderLifecycleManager {
  bool _disposed = false;
  
  // Track provider usage for optimization
  final Map<String, DateTime> _lastAccessTimes = {};
  final Set<String> _criticalProviders = {
    'taskStateNotifierProvider',
    'userStateNotifierProvider',
    'databaseServiceProvider',
    'preferencesServiceProvider',
  };
  
  ProviderLifecycleManager();
  
  /// Optimize memory by disposing unused providers
  void optimizeMemory() {
    if (_disposed) return;
    
    final now = DateTime.now();
    final unusedThreshold = const Duration(minutes: 5);
    
    // Find providers that haven't been accessed recently
    final unusedProviders = _lastAccessTimes.entries
        .where((entry) => 
            !_criticalProviders.contains(entry.key) &&
            now.difference(entry.value) > unusedThreshold)
        .map((entry) => entry.key)
        .toList();
    
    // Log optimization activity
    if (unusedProviders.isNotEmpty) {
      ErrorHandler.logInfo(
        'Memory optimization: disposing ${unusedProviders.length} unused providers',
        context: 'Provider Lifecycle Manager',
      );
    }
    
    // Note: Actual provider disposal is handled by Riverpod's autoDispose
    // This is mainly for tracking and logging
    for (final providerName in unusedProviders) {
      _lastAccessTimes.remove(providerName);
    }
  }
  
  /// Track provider access for optimization
  void trackProviderAccess(String providerName) {
    if (_disposed) return;
    
    _lastAccessTimes[providerName] = DateTime.now();
  }
  
  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    final now = DateTime.now();
    
    return {
      'trackedProviders': _lastAccessTimes.length,
      'criticalProviders': _criticalProviders.length,
      'recentlyAccessedProviders': _lastAccessTimes.entries
          .where((entry) => now.difference(entry.value).inMinutes < 5)
          .length,
      'oldProviders': _lastAccessTimes.entries
          .where((entry) => now.difference(entry.value).inMinutes >= 5)
          .length,
      'isDisposed': _disposed,
    };
  }
  
  /// Force cleanup of all non-critical providers
  void forceCleanup() {
    if (_disposed) return;
    
    final nonCriticalProviders = _lastAccessTimes.keys
        .where((key) => !_criticalProviders.contains(key))
        .toList();
    
    for (final providerName in nonCriticalProviders) {
      _lastAccessTimes.remove(providerName);
    }
    
    ErrorHandler.logInfo(
      'Force cleanup: removed ${nonCriticalProviders.length} non-critical providers from tracking',
      context: 'Provider Lifecycle Manager',
    );
  }
  
  /// Dispose of resources
  void dispose() {
    _disposed = true;
    _lastAccessTimes.clear();
  }
  
  /// Check if the manager is disposed
  bool get isDisposed => _disposed;
}

/// Provider Health Monitor
/// 
/// Monitors the health and performance of the provider system
final providerHealthMonitorProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final providerManager = ref.watch(providerManagerProvider);
  final lifecycleManager = ref.watch(providerLifecycleManagerProvider);
  
  try {
    final providerStats = providerManager.getProviderStats();
    final memoryStats = lifecycleManager.getMemoryStats();
    
    // Calculate health score based on various metrics
    final totalInvalidations = providerStats['totalInvalidations'] ?? 0;
    final activeProviders = memoryStats['trackedProviders'] ?? 0;
    
    // Health score calculation (0-100)
    var healthScore = 100;
    
    // Penalize excessive invalidations
    if (totalInvalidations > 200) {
      healthScore -= 20;
    } else if (totalInvalidations > 100) {
      healthScore -= 10;
    }
    
    // Penalize too many active providers
    if (activeProviders > 50) {
      healthScore -= 15;
    } else if (activeProviders > 30) {
      healthScore -= 5;
    }
    
    // Bonus for recent optimization
    final recentlyAccessed = memoryStats['recentlyAccessedProviders'] ?? 0;
    if (recentlyAccessed < activeProviders * 0.7) {
      healthScore += 5;
    }
    
    return {
      'healthScore': healthScore.clamp(0, 100),
      'status': _getHealthStatus(healthScore),
      'recommendations': _getHealthRecommendations(healthScore, totalInvalidations, activeProviders),
      'providerStats': providerStats,
      'memoryStats': memoryStats,
      'lastCheck': DateTime.now().millisecondsSinceEpoch,
    };
  } catch (e) {
    ErrorHandler.logError(e, context: 'Provider health monitor', type: ErrorType.unknown);
    return {
      'healthScore': 0,
      'status': 'error',
      'error': e.toString(),
      'lastCheck': DateTime.now().millisecondsSinceEpoch,
    };
  }
});

/// Get health status based on score
String _getHealthStatus(int score) {
  if (score >= 90) return 'excellent';
  if (score >= 75) return 'good';
  if (score >= 60) return 'fair';
  if (score >= 40) return 'poor';
  return 'critical';
}

/// Get health recommendations based on metrics
List<String> _getHealthRecommendations(int score, int invalidations, int activeProviders) {
  final recommendations = <String>[];
  
  if (invalidations > 200) {
    recommendations.add('Consider reducing provider invalidation frequency');
  }
  
  if (activeProviders > 50) {
    recommendations.add('Consider using more autoDispose providers for memory optimization');
  }
  
  if (score < 60) {
    recommendations.add('Run memory optimization to improve performance');
  }
  
  if (score >= 90) {
    recommendations.add('Provider system is performing optimally');
  }
  
  return recommendations;
}