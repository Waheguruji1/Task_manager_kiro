import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';
import '../services/share_service.dart';
import '../models/task.dart';
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
final everydayTasksProvider = FutureProvider<List<Task>>((ref) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  return await dbService.getEverydayTasks();
});

/// Routine Tasks Provider
/// 
/// Provides a list of routine tasks
final routineTasksProvider = FutureProvider<List<Task>>((ref) async {
  final dbService = await ref.watch(asyncDatabaseServiceProvider.future);
  return await dbService.getRoutineTasks();
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
  return TaskStateNotifier(dbService);
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