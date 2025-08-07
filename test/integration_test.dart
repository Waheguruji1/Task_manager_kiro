import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/models/achievement.dart';
import 'package:task_manager_kiro/services/database_service.dart';
import 'package:task_manager_kiro/services/task_cleanup_service.dart';
import 'package:task_manager_kiro/services/achievement_service.dart';
import 'package:task_manager_kiro/services/stats_service.dart';

void main() {
  group('Final Integration Tests', () {
    late DatabaseService databaseService;
    late TaskCleanupService cleanupService;
    late AchievementService achievementService;
    late StatsService statsService;

    setUpAll(() async {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize services that don't require platform channels
      databaseService = await DatabaseService.getInstance();
      cleanupService = TaskCleanupService();
      achievementService = await AchievementService.getInstance();
      statsService = StatsService();
    });

    tearDownAll(() async {
      await databaseService.close();
    });

    setUp(() async {
      // Clear database before each test
      final allTasks = await databaseService.getAllTasks();
      for (final task in allTasks) {
        if (task.id != null) {
          await databaseService.deleteTask(task.id!);
        }
      }
    });

    test('Task creation with priority integration', () async {
      // Test creating a high priority task
      final task = Task(
        title: 'High Priority Task',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        notificationTime: DateTime.now().add(const Duration(hours: 1)),
      );

      // Add task directly to database
      final taskId = await databaseService.createTask(task);
      expect(taskId, greaterThan(0));

      // Verify task was created with correct priority
      final tasks = await databaseService.getEverydayTasks();
      expect(tasks.length, equals(1));
      expect(tasks.first.priority, equals(TaskPriority.high));
      expect(tasks.first.notificationTime, isNotNull);
    });

    test('Task priority sorting integration', () async {
      // Create tasks with different priorities
      final highPriorityTask = Task(
        title: 'High Priority Task',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
      );

      final mediumPriorityTask = Task(
        title: 'Medium Priority Task',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
      );

      final noPriorityTask = Task(
        title: 'No Priority Task',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.none,
      );

      // Add tasks in random order
      await databaseService.createTask(noPriorityTask);
      await databaseService.createTask(highPriorityTask);
      await databaseService.createTask(mediumPriorityTask);

      // Verify tasks are sorted by priority
      final tasks = await databaseService.getEverydayTasks();
      final sortedTasks = Task.sortByPriority(tasks);
      
      expect(sortedTasks.length, equals(3));
      expect(sortedTasks[0].priority, equals(TaskPriority.high));
      expect(sortedTasks[1].priority, equals(TaskPriority.medium));
      expect(sortedTasks[2].priority, equals(TaskPriority.none));
    });

    test('Stats service integration', () async {
      // Create tasks for stats calculation
      final completedTask = Task(
        title: 'Completed Task',
        isRoutine: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      final pendingTask = Task(
        title: 'Pending Task',
        isRoutine: false,
        createdAt: DateTime.now(),
      );

      await databaseService.createTask(completedTask);
      await databaseService.createTask(pendingTask);

      // Test heatmap data calculation
      final allTasks = await databaseService.getAllTasks();
      final heatmapData = statsService.calculateCompletionHeatmapData(allTasks);
      
      expect(heatmapData, isNotEmpty);
      expect(heatmapData.values.any((count) => count > 0), isTrue);

      // Test creation vs completion heatmap
      final creationCompletionData = statsService.calculateCreationCompletionHeatmapData(allTasks);
      expect(creationCompletionData, isNotEmpty);
    });

    test('Task cleanup service integration', () async {
      // Create old completed tasks
      final oldCompletedTask = Task(
        title: 'Old Completed Task',
        isRoutine: false,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 90)),
      );

      final recentCompletedTask = Task(
        title: 'Recent Completed Task',
        isRoutine: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      final routineTask = Task(
        title: 'Routine Task',
        isRoutine: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 90)),
      );

      // Add tasks
      await databaseService.createTask(oldCompletedTask);
      await databaseService.createTask(recentCompletedTask);
      await databaseService.createTask(routineTask);

      // Verify all tasks were created
      var allTasks = await databaseService.getAllTasks();
      expect(allTasks.length, equals(3));

      // Perform cleanup
      final cleanupSuccess = await cleanupService.performCleanup(databaseService);
      expect(cleanupSuccess, isTrue);

      // Verify only old completed everyday task was deleted
      allTasks = await databaseService.getAllTasks();
      expect(allTasks.length, equals(2)); // Recent task and routine task should remain

      final remainingTasks = allTasks.map((t) => t.title).toList();
      expect(remainingTasks, contains('Recent Completed Task'));
      expect(remainingTasks, contains('Routine Task'));
      expect(remainingTasks, isNot(contains('Old Completed Task')));
    });

    test('Achievement integration with task operations', () async {
      // Create and complete a task to trigger first task achievement
      final task = Task(
        title: 'First Task',
        isRoutine: false,
        createdAt: DateTime.now(),
      );

      await databaseService.createTask(task);
      
      // Complete the task
      final tasks = await databaseService.getEverydayTasks();
      final taskId = tasks.first.id!;
      await databaseService.toggleTaskCompletion(taskId);

      // Manually trigger achievement checking
      await achievementService.checkAndUpdateAchievements();

      // Check if first task achievement was earned
      final achievements = await achievementService.getAllAchievements();
      final firstTaskAchievement = achievements.firstWhere(
        (a) => a.id == 'first_task',
        orElse: () => throw Exception('First task achievement not found'),
      );
      
      expect(firstTaskAchievement.isEarned, isTrue);
      expect(firstTaskAchievement.earnedAt, isNotNull);
    });

    test('Complete user workflow integration', () async {
      // Simulate complete user workflow
      
      // 1. Create routine task
      final routineTask = Task(
        title: 'Daily Exercise',
        isRoutine: true,
        createdAt: DateTime.now(),
      );
      await databaseService.createTask(routineTask);
      
      // 2. Create high priority everyday task with notification
      final highPriorityTask = Task(
        title: 'Important Meeting',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        notificationTime: DateTime.now().add(const Duration(hours: 2)),
      );
      await databaseService.createTask(highPriorityTask);
      
      // 3. Create medium priority task
      final mediumPriorityTask = Task(
        title: 'Review Documents',
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
      );
      await databaseService.createTask(mediumPriorityTask);
      
      // 4. Verify task organization
      final everydayTasks = await databaseService.getEverydayTasks();
      final routineTasks = await databaseService.getRoutineTasks();
      
      expect(everydayTasks.length, equals(2)); // High and medium priority tasks
      expect(routineTasks.length, equals(1)); // Routine task
      
      // 5. Verify priority sorting
      final sortedEverydayTasks = Task.sortByPriority(everydayTasks);
      expect(sortedEverydayTasks[0].priority, equals(TaskPriority.high));
      expect(sortedEverydayTasks[1].priority, equals(TaskPriority.medium));
      
      // 6. Complete tasks and check achievements
      for (final task in everydayTasks) {
        await databaseService.toggleTaskCompletion(task.id!);
      }
      
      // Trigger achievement checking
      await achievementService.checkAndUpdateAchievements();
      
      // 7. Verify achievements were updated
      final achievements = await achievementService.getAllAchievements();
      final firstTaskAchievement = achievements.firstWhere((a) => a.id == 'first_task');
      expect(firstTaskAchievement.isEarned, isTrue);
      
      // 8. Test cleanup statistics
      final cleanupStats = cleanupService.getCleanupStatistics(
        [...everydayTasks, ...routineTasks]
      );
      expect(cleanupStats['totalTasks'], equals(3));
      expect(cleanupStats['routineTasks'], equals(1));
    });

    test('Error handling and recovery integration', () async {
      // Test error handling in various scenarios
      
      // 1. Test invalid task creation
      final invalidTask = Task(
        title: '', // Empty title should cause validation error
        isRoutine: false,
        createdAt: DateTime.now(),
      );
      
      // This should fail validation at the UI level, but let's test service level
      try {
        await databaseService.createTask(invalidTask);
        fail('Should have thrown an error for invalid task');
      } catch (e) {
        expect(e, isNotNull);
      }
      
      // 2. Test cleanup with empty database
      final cleanupSuccess = await cleanupService.performCleanup(databaseService);
      expect(cleanupSuccess, isTrue); // Should succeed even with no tasks to clean
    });

    test('Performance and memory management integration', () async {
      // Test performance with multiple tasks
      final tasks = <Task>[];
      
      // Create 50 tasks with various configurations
      for (int i = 0; i < 50; i++) {
        final task = Task(
          title: 'Task $i',
          isRoutine: i % 5 == 0, // Every 5th task is routine
          createdAt: DateTime.now().subtract(Duration(days: i)),
          priority: TaskPriority.values[i % 3], // Cycle through priorities
          notificationTime: i % 3 == 0 ? DateTime.now().add(Duration(hours: i + 1)) : null,
        );
        tasks.add(task);
      }
      
      // Add all tasks
      for (final task in tasks) {
        await databaseService.createTask(task);
      }
      
      // Verify all tasks were created
      final allTasks = await databaseService.getAllTasks();
      expect(allTasks.length, equals(50));
      
      // Test sorting performance
      final startTime = DateTime.now();
      final sortedTasks = Task.sortByPriority(allTasks);
      final sortTime = DateTime.now().difference(startTime);
      
      expect(sortedTasks.length, equals(50));
      expect(sortTime.inMilliseconds, lessThan(100)); // Should sort quickly
      
      // Test cleanup performance
      final cleanupStartTime = DateTime.now();
      await cleanupService.performCleanup(databaseService);
      final cleanupTime = DateTime.now().difference(cleanupStartTime);
      
      expect(cleanupTime.inSeconds, lessThan(5)); // Should complete quickly
      
      // Test stats calculation performance
      final statsStartTime = DateTime.now();
      final heatmapData = statsService.calculateCompletionHeatmapData(allTasks);
      final statsTime = DateTime.now().difference(statsStartTime);
      
      expect(heatmapData, isNotNull);
      expect(statsTime.inSeconds, lessThan(2)); // Should calculate quickly
    });
  });
}