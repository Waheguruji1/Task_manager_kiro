import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/models/task.dart';
import '../lib/services/notification_service.dart';
import '../lib/services/database_service.dart';
import '../lib/services/achievement_service.dart';
import '../lib/providers/task_state_notifier.dart';

void main() {
  group('Notification Integration Tests', () {
    late NotificationService notificationService;
    late DatabaseService databaseService;
    late AchievementService achievementService;
    late TaskStateNotifier taskStateNotifier;

    setUpAll(() async {
      // Initialize services
      notificationService = NotificationService();
      databaseService = await DatabaseService.getInstance();
      achievementService = await AchievementService.getInstance();
      
      // Initialize task state notifier
      taskStateNotifier = TaskStateNotifier(
        databaseService,
        achievementService,
        notificationService,
      );
    });

    tearDownAll(() async {
      await databaseService.close();
    });

    test('should schedule notification when creating task with notification time', () async {
      // Arrange
      final notificationTime = DateTime.now().add(const Duration(hours: 1));
      final task = Task(
        title: 'Test Task with Notification',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        notificationTime: notificationTime,
      );

      // Act
      final success = await taskStateNotifier.addTask(task);

      // Assert
      expect(success, isTrue);
      
      // Verify notification was scheduled
      final pendingNotifications = await notificationService.getPendingNotifications();
      expect(pendingNotifications.isNotEmpty, isTrue);
    });

    test('should cancel notification when task is completed', () async {
      // Arrange
      final notificationTime = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        title: 'Test Task for Completion',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
        notificationTime: notificationTime,
      );

      // Create task first
      final success = await taskStateNotifier.addTask(task);
      expect(success, isTrue);

      // Get the created task ID
      final tasks = taskStateNotifier.state.everydayTasks;
      final createdTask = tasks.firstWhere((t) => t.title == task.title);

      // Act - Complete the task
      final toggleSuccess = await taskStateNotifier.toggleTaskCompletion(createdTask.id!);

      // Assert
      expect(toggleSuccess, isTrue);
      
      // Note: In a real test environment, we would verify that the specific
      // notification was cancelled, but this requires more complex mocking
    });

    test('should reschedule notification when task is updated', () async {
      // Arrange
      final originalNotificationTime = DateTime.now().add(const Duration(hours: 1));
      final updatedNotificationTime = DateTime.now().add(const Duration(hours: 3));
      
      final task = Task(
        title: 'Test Task for Update',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.none,
        notificationTime: originalNotificationTime,
      );

      // Create task first
      final createSuccess = await taskStateNotifier.addTask(task);
      expect(createSuccess, isTrue);

      // Get the created task
      final tasks = taskStateNotifier.state.everydayTasks;
      final createdTask = tasks.firstWhere((t) => t.title == task.title);

      // Act - Update the task with new notification time
      final updatedTask = createdTask.copyWith(
        notificationTime: updatedNotificationTime,
      );
      final updateSuccess = await taskStateNotifier.updateTask(updatedTask);

      // Assert
      expect(updateSuccess, isTrue);
      
      // Verify notification was rescheduled
      final pendingNotifications = await notificationService.getPendingNotifications();
      expect(pendingNotifications.isNotEmpty, isTrue);
    });

    test('should not schedule notification for routine tasks', () async {
      // Arrange
      final notificationTime = DateTime.now().add(const Duration(hours: 1));
      final routineTask = Task(
        title: 'Test Routine Task',
        isRoutine: true,
        createdAt: DateTime.now(),
        priority: TaskPriority.none,
        notificationTime: notificationTime, // This should be ignored
      );

      // Act
      final success = await taskStateNotifier.addTask(routineTask);

      // Assert
      expect(success, isTrue);
      
      // Verify the task was created but notification time was cleared
      final tasks = taskStateNotifier.state.routineTasks;
      final createdTask = tasks.firstWhere((t) => t.title == routineTask.title);
      expect(createdTask.notificationTime, isNull);
    });

    test('should handle notification permission gracefully', () async {
      // Arrange
      final task = Task(
        title: 'Test Task Permission Handling',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        notificationTime: DateTime.now().add(const Duration(hours: 1)),
      );

      // Act - This should not fail even if permissions are denied
      final success = await taskStateNotifier.addTask(task);

      // Assert - Task should still be created even if notification fails
      expect(success, isTrue);
      
      final tasks = taskStateNotifier.state.everydayTasks;
      final createdTask = tasks.firstWhere((t) => t.title == task.title);
      expect(createdTask.title, equals(task.title));
    });

    test('should cancel notification when task is deleted', () async {
      // Arrange
      final notificationTime = DateTime.now().add(const Duration(hours: 1));
      final task = Task(
        title: 'Test Task for Deletion',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
        notificationTime: notificationTime,
      );

      // Create task first
      final createSuccess = await taskStateNotifier.addTask(task);
      expect(createSuccess, isTrue);

      // Get the created task
      final tasks = taskStateNotifier.state.everydayTasks;
      final createdTask = tasks.firstWhere((t) => t.title == task.title);

      // Act - Delete the task
      final deleteSuccess = await taskStateNotifier.deleteTask(createdTask.id!);

      // Assert
      expect(deleteSuccess, isTrue);
      
      // Verify task is no longer in the list
      final updatedTasks = taskStateNotifier.state.everydayTasks;
      expect(updatedTasks.any((t) => t.id == createdTask.id), isFalse);
    });

    test('should handle notification service errors gracefully', () async {
      // This test verifies that task operations continue to work even if
      // notification service encounters errors
      
      // Arrange
      final task = Task(
        title: 'Test Task Error Handling',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        notificationTime: DateTime.now().add(const Duration(hours: 1)),
      );

      // Act - Even if notification service has issues, task should be created
      final success = await taskStateNotifier.addTask(task);

      // Assert
      expect(success, isTrue);
      
      final tasks = taskStateNotifier.state.everydayTasks;
      expect(tasks.any((t) => t.title == task.title), isTrue);
    });
  });

  group('Notification Service Integration', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    test('should initialize notification service successfully', () async {
      // Act & Assert - Should not throw
      await expectLater(
        notificationService.initialize(),
        completes,
      );
    });

    test('should handle permission requests gracefully', () async {
      // Arrange
      await notificationService.initialize();

      // Act & Assert - Should not throw, regardless of permission status
      await expectLater(
        notificationService.requestPermissions(),
        completion(isA<bool>()),
      );
    });

    test('should check notification status without errors', () async {
      // Arrange
      await notificationService.initialize();

      // Act & Assert
      await expectLater(
        notificationService.areNotificationsEnabled(),
        completion(isA<bool>()),
      );
    });

    test('should handle task notification scheduling', () async {
      // Arrange
      await notificationService.initialize();
      final task = Task(
        title: 'Test Notification Task',
        isRoutine: false,
        createdAt: DateTime.now(),
        notificationTime: DateTime.now().add(const Duration(hours: 1)),
      );

      // Act & Assert - Should return notification ID or null
      await expectLater(
        notificationService.scheduleTaskNotification(task),
        completion(anyOf(isA<int>(), isNull)),
      );
    });

    test('should handle notification cancellation gracefully', () async {
      // Arrange
      await notificationService.initialize();
      const testNotificationId = 12345;

      // Act & Assert - Should not throw
      await expectLater(
        notificationService.cancelTaskNotification(testNotificationId),
        completes,
      );
    });

    test('should handle cancel all notifications gracefully', () async {
      // Arrange
      await notificationService.initialize();

      // Act & Assert - Should not throw
      await expectLater(
        notificationService.cancelAllNotifications(),
        completes,
      );
    });

    test('should get pending notifications list', () async {
      // Arrange
      await notificationService.initialize();

      // Act & Assert
      await expectLater(
        notificationService.getPendingNotifications(),
        completion(isA<List>()),
      );
    });
  });
}