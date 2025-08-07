import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import '../services/task_cleanup_service.dart';
import '../models/task.dart';
import '../models/achievement.dart';
import 'task_state_notifier.dart';
import 'user_state_notifier.dart';

/// Database Service Provider
/// 
/// Provides a singleton instance of DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('DatabaseService must be initialized asynchronously');
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
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('PreferencesService must be initialized asynchronously');
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
final taskStateNotifierProvider = StateNotifierProvider<TaskStateNotifier, TaskState>((ref) {
  throw UnimplementedError('TaskStateNotifier must be initialized with DatabaseService');
});

/// Async Task State Notifier Provider
/// 
/// Provides an asynchronously initialized TaskStateNotifier
final asyncTaskStateNotifierProvider = FutureProvider<TaskStateNotifier>((ref) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  final achievementService = await ref.watch(achievementServiceProvider.future);
  final notificationService = ref.watch(notificationServiceProvider);
  return TaskStateNotifier(dbService, achievementService, notificationService);
});

/// User State Notifier Provider
/// 
/// Provides a StateNotifier for managing user authentication state and operations
final userStateNotifierProvider = StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  throw UnimplementedError('UserStateNotifier must be initialized with PreferencesService');
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
final allAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  return await achievementService.getAllAchievements();
});

/// Earned Achievements Provider
/// 
/// Provides a list of earned achievements
final earnedAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  return await achievementService.getEarnedAchievements();
});

/// Unearned Achievements Provider
/// 
/// Provides a list of unearned achievements with progress
final unearnedAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final achievementService = await ref.watch(achievementServiceProvider.future);
  return await achievementService.getUnearnedAchievements();
});

/// Completion Heatmap Data Provider
/// 
/// Provides heatmap data for task completion activity
final completionHeatmapDataProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  final statsService = ref.watch(statsServiceProvider);
  final tasks = await ref.watch(allTasksProvider.future);
  return statsService.calculateCompletionHeatmapData(tasks);
});

/// Creation vs Completion Heatmap Data Provider
/// 
/// Provides heatmap data for task creation vs completion
final creationCompletionHeatmapDataProvider = FutureProvider<Map<DateTime, Map<String, int>>>((ref) async {
  final statsService = ref.watch(statsServiceProvider);
  final tasks = await ref.watch(allTasksProvider.future);
  return statsService.calculateCreationCompletionHeatmapData(tasks);
});

/// Notification Service Provider
/// 
/// Provides a singleton instance of NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
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
  return await cleanupService.performCleanupIfNeeded(dbService);
});