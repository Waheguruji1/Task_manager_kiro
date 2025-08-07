import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/models/database.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:matcher/matcher.dart' as matcher;

void main() {
  group('Database Migration Tests', () {
    late AppDatabase database;

    setUp(() async {
      // Create an in-memory database for testing
      database = AppDatabase();
    });

    tearDown(() async {
      await database.close();
    });

    test('should create tasks with priority and notification fields', () async {
      final now = DateTime.now();
      final notificationTime = now.add(const Duration(hours: 1));
      
      // Insert a task with priority and notification directly into database
      final taskId = await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Test Task with Priority'),
        description: const Value('This is a test task with high priority and notification'),
        createdAt: Value(now),
        priority: const Value(2), // TaskPriority.high = 2
        notificationTime: Value(notificationTime),
        notificationId: const Value(12345),
      ));

      expect(taskId, greaterThan(0));

      // Retrieve the task and verify priority and notification fields
      final retrievedTask = await (database.select(database.tasks)
        ..where((t) => t.id.equals(taskId))).getSingle();
      
      expect(retrievedTask.priority, equals(2)); // TaskPriority.high
      expect(retrievedTask.notificationTime, equals(notificationTime));
      expect(retrievedTask.notificationId, equals(12345));
    });

    test('should handle tasks with default priority (none)', () async {
      final now = DateTime.now();
      
      // Insert a task without explicit priority (should default to 0)
      final taskId = await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Test Task No Priority'),
        description: const Value('This is a test task with default priority'),
        createdAt: Value(now),
        // priority not specified, should default to 0
      ));

      expect(taskId, greaterThan(0));

      // Retrieve the task and verify default priority
      final retrievedTask = await (database.select(database.tasks)
        ..where((t) => t.id.equals(taskId))).getSingle();
      
      expect(retrievedTask.priority, equals(0)); // TaskPriority.none
      expect(retrievedTask.notificationTime, matcher.isNull);
      expect(retrievedTask.notificationId, matcher.isNull);
    });

    test('should sort tasks by priority correctly', () async {
      final now = DateTime.now();
      
      // Insert tasks with different priorities
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('No Priority Task'),
        createdAt: Value(now),
        priority: const Value(0), // TaskPriority.none
      ));
      
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('High Priority Task'),
        createdAt: Value(now.add(const Duration(minutes: 1))),
        priority: const Value(2), // TaskPriority.high
      ));
      
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Medium Priority Task'),
        createdAt: Value(now.add(const Duration(minutes: 2))),
        priority: const Value(1), // TaskPriority.medium
      ));

      // Get tasks sorted by priority (descending) then by creation date
      final sortedTasks = await database.getEverydayTasksSortedByPriority();
      
      // Verify sorting order (High → Medium → None)
      expect(sortedTasks.length, equals(3));
      expect(sortedTasks[0].priority, equals(2)); // High
      expect(sortedTasks[1].priority, equals(1)); // Medium
      expect(sortedTasks[2].priority, equals(0)); // None
    });

    test('should filter tasks by priority', () async {
      final now = DateTime.now();
      
      // Insert tasks with different priorities
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('High Priority Task 1'),
        createdAt: Value(now),
        priority: const Value(2), // TaskPriority.high
      ));
      
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Medium Priority Task'),
        createdAt: Value(now.add(const Duration(minutes: 1))),
        priority: const Value(1), // TaskPriority.medium
      ));
      
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('High Priority Task 2'),
        createdAt: Value(now.add(const Duration(minutes: 2))),
        priority: const Value(2), // TaskPriority.high
      ));

      // Get only high priority tasks
      final highPriorityTasks = await database.getTasksByPriority(2);
      
      // Verify filtering
      expect(highPriorityTasks.length, equals(2));
      for (final task in highPriorityTasks) {
        expect(task.priority, equals(2)); // TaskPriority.high
      }
    });

    test('should handle notification-related queries', () async {
      final now = DateTime.now();
      final notificationTime = now.add(const Duration(hours: 2));
      
      // Insert task with notification
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Task with Notification'),
        createdAt: Value(now),
        notificationTime: Value(notificationTime),
        notificationId: const Value(54321),
      ));
      
      // Insert task without notification
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Task without Notification'),
        createdAt: Value(now.add(const Duration(minutes: 1))),
      ));

      // Get tasks with notifications
      final tasksWithNotifications = await database.getTasksWithNotifications();
      expect(tasksWithNotifications.length, equals(1));
      expect(tasksWithNotifications[0].notificationTime, matcher.isNotNull);

      // Get task by notification ID
      final taskByNotificationId = await database.getTaskByNotificationId(54321);
      expect(taskByNotificationId, matcher.isNotNull);
      expect(taskByNotificationId!.title, equals('Task with Notification'));
    });

    test('should get tasks with notifications for specific date', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      // Insert task with notification for today
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Task for Today'),
        createdAt: Value(today),
        notificationTime: Value(today.add(const Duration(hours: 2))),
        notificationId: const Value(11111),
      ));
      
      // Insert task with notification for tomorrow
      await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Task for Tomorrow'),
        createdAt: Value(today),
        notificationTime: Value(tomorrow.add(const Duration(hours: 2))),
        notificationId: const Value(22222),
      ));

      // Get tasks with notifications for today
      final todayTasks = await database.getTasksWithNotificationsForDate(today);
      expect(todayTasks.length, equals(1));
      expect(todayTasks[0].title, equals('Task for Today'));

      // Get tasks with notifications for tomorrow
      final tomorrowTasks = await database.getTasksWithNotificationsForDate(tomorrow);
      expect(tomorrowTasks.length, equals(1));
      expect(tomorrowTasks[0].title, equals('Task for Tomorrow'));
    });

    test('should verify database schema includes new columns', () async {
      // This test verifies that the migration worked and new columns exist
      final now = DateTime.now();
      
      // Try to insert a task with all new fields
      final taskId = await database.into(database.tasks).insert(TasksCompanion(
        title: const Value('Schema Test Task'),
        createdAt: Value(now),
        priority: const Value(1),
        notificationTime: Value(now.add(const Duration(hours: 1))),
        notificationId: const Value(99999),
      ));

      expect(taskId, greaterThan(0));

      // Verify all fields were saved correctly
      final task = await (database.select(database.tasks)
        ..where((t) => t.id.equals(taskId))).getSingle();
      
      expect(task.priority, equals(1));
      expect(task.notificationTime, matcher.isNotNull);
      expect(task.notificationId, equals(99999));
    });
  });
}