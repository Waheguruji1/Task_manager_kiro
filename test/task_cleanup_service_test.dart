import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/services/task_cleanup_service.dart';

void main() {
  group('TaskCleanupService', () {
    late TaskCleanupService cleanupService;

    setUp(() {
      cleanupService = TaskCleanupService();
    });

    group('getTasksToCleanup', () {
      test('should identify old completed everyday tasks for cleanup', () async {
        // Arrange
        final now = DateTime.now();
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

        final tasks = [
          // Old completed everyday task - should be cleaned up
          Task(
            id: 1,
            title: 'Old completed task',
            isCompleted: true,
            isRoutine: false,
            createdAt: threeMonthsAgo,
            completedAt: threeMonthsAgo,
          ),
          // Recent completed everyday task - should NOT be cleaned up
          Task(
            id: 2,
            title: 'Recent completed task',
            isCompleted: true,
            isRoutine: false,
            createdAt: oneMonthAgo,
            completedAt: oneMonthAgo,
          ),
          // Old routine task - should NOT be cleaned up
          Task(
            id: 3,
            title: 'Old routine task',
            isCompleted: true,
            isRoutine: true,
            createdAt: threeMonthsAgo,
            completedAt: threeMonthsAgo,
          ),
          // Old incomplete task - should NOT be cleaned up
          Task(
            id: 4,
            title: 'Old incomplete task',
            isCompleted: false,
            isRoutine: false,
            createdAt: threeMonthsAgo,
          ),
          // Old routine task instance - should NOT be cleaned up
          Task(
            id: 5,
            title: 'Old routine instance',
            isCompleted: true,
            isRoutine: false,
            createdAt: threeMonthsAgo,
            completedAt: threeMonthsAgo,
            routineTaskId: 3,
          ),
        ];

        // Act
        final tasksToCleanup = await cleanupService.getTasksToCleanup(tasks);

        // Assert
        expect(tasksToCleanup.length, equals(1));
        expect(tasksToCleanup.first.id, equals(1));
        expect(tasksToCleanup.first.title, equals('Old completed task'));
      });

      test('should return empty list when no tasks need cleanup', () async {
        // Arrange
        final now = DateTime.now();
        final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

        final tasks = [
          // Recent completed task
          Task(
            id: 1,
            title: 'Recent task',
            isCompleted: true,
            isRoutine: false,
            createdAt: oneMonthAgo,
            completedAt: oneMonthAgo,
          ),
          // Routine task
          Task(
            id: 2,
            title: 'Routine task',
            isCompleted: true,
            isRoutine: true,
            createdAt: oneMonthAgo,
            completedAt: oneMonthAgo,
          ),
        ];

        // Act
        final tasksToCleanup = await cleanupService.getTasksToCleanup(tasks);

        // Assert
        expect(tasksToCleanup, isEmpty);
      });
    });

    group('getCleanupStatistics', () {
      test('should calculate correct cleanup statistics', () {
        // Arrange
        final now = DateTime.now();
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

        final tasks = [
          // Old completed everyday task - eligible for cleanup
          Task(
            id: 1,
            title: 'Old completed task',
            isCompleted: true,
            isRoutine: false,
            createdAt: threeMonthsAgo,
            completedAt: threeMonthsAgo,
          ),
          // Recent completed task
          Task(
            id: 2,
            title: 'Recent task',
            isCompleted: true,
            isRoutine: false,
            createdAt: oneMonthAgo,
            completedAt: oneMonthAgo,
          ),
          // Routine task
          Task(
            id: 3,
            title: 'Routine task',
            isCompleted: true,
            isRoutine: true,
            createdAt: threeMonthsAgo,
            completedAt: threeMonthsAgo,
          ),
          // Incomplete task
          Task(
            id: 4,
            title: 'Incomplete task',
            isCompleted: false,
            isRoutine: false,
            createdAt: now,
          ),
        ];

        // Act
        final stats = cleanupService.getCleanupStatistics(tasks);

        // Assert
        expect(stats['totalTasks'], equals(4));
        expect(stats['completedTasks'], equals(3));
        expect(stats['routineTasks'], equals(1));
        expect(stats['eligibleForCleanup'], equals(1));
        expect(stats['thresholdMonths'], equals(2));
      });
    });

    group('shouldPerformCleanup', () {
      test('should return true when enough tasks are eligible for cleanup', () {
        // Arrange
        final now = DateTime.now();
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

        final tasks = List.generate(15, (index) => Task(
          id: index + 1,
          title: 'Old task $index',
          isCompleted: true,
          isRoutine: false,
          createdAt: threeMonthsAgo,
          completedAt: threeMonthsAgo,
        ));

        // Act
        final shouldCleanup = cleanupService.shouldPerformCleanup(tasks, minimumTasksForCleanup: 10);

        // Assert
        expect(shouldCleanup, isTrue);
      });

      test('should return false when not enough tasks are eligible for cleanup', () {
        // Arrange
        final now = DateTime.now();
        final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

        final tasks = List.generate(5, (index) => Task(
          id: index + 1,
          title: 'Recent task $index',
          isCompleted: true,
          isRoutine: false,
          createdAt: oneMonthAgo,
          completedAt: oneMonthAgo,
        ));

        // Act
        final shouldCleanup = cleanupService.shouldPerformCleanup(tasks, minimumTasksForCleanup: 10);

        // Assert
        expect(shouldCleanup, isFalse);
      });
    });
  });
}