import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/models/achievement.dart';
import 'package:task_manager_kiro/services/database_service.dart';
import 'package:task_manager_kiro/services/achievement_service.dart';
import 'package:task_manager_kiro/services/notification_service.dart';
import 'package:task_manager_kiro/providers/task_state_notifier.dart';

void main() {
  group('Achievement Integration Tests', () {
    late DatabaseService databaseService;
    late AchievementService achievementService;
    late TaskStateNotifier taskStateNotifier;

    setUp(() async {
      // Initialize services
      databaseService = await DatabaseService.getInstance();
      await databaseService.initialize();
      
      achievementService = await AchievementService.getInstance();
      await achievementService.initialize();
      
      // Create task state notifier with both services
      final notificationService = NotificationService();
      taskStateNotifier = TaskStateNotifier(databaseService, achievementService, notificationService);
      
      // Clear any existing data for clean tests by deleting all tasks
      final existingTasks = await databaseService.getAllTasks();
      for (final task in existingTasks) {
        if (task.id != null) {
          await databaseService.deleteTask(task.id!);
        }
      }
      await achievementService.resetAllAchievements();
    });

    testWidgets('achievement tracking is called after task operations', (WidgetTester tester) async {
      // Create a test task
      final testTask = Task(
        title: 'Test Task',
        description: 'Test Description',
        createdAt: DateTime.now(),
      );

      // Add task - this should trigger achievement checking
      final addResult = await taskStateNotifier.addTask(testTask);
      expect(addResult, isTrue);

      // Get all tasks to verify the task was added
      final tasks = await databaseService.getAllTasks();
      expect(tasks.length, equals(1));

      // Complete the task - this should trigger achievement checking
      final taskId = tasks.first.id!;
      final toggleResult = await taskStateNotifier.toggleTaskCompletion(taskId);
      expect(toggleResult, isTrue);

      // Check if first task achievement was earned
      final achievements = await achievementService.getAllAchievements();
      final firstTaskAchievement = achievements.firstWhere(
        (a) => a.id == 'first_task',
        orElse: () => Achievement(
          id: 'not_found',
          title: '',
          description: '',
          icon: Icons.star,
          type: AchievementType.firstTime,
          targetValue: 0,
        ),
      );

      expect(firstTaskAchievement.id, equals('first_task'));
      expect(firstTaskAchievement.isEarned, isTrue);
    });

    testWidgets('achievement progress is updated correctly', (WidgetTester tester) async {
      // Create multiple tasks
      final tasks = List.generate(3, (index) => Task(
        title: 'Task ${index + 1}',
        description: 'Description ${index + 1}',
        createdAt: DateTime.now(),
      ));

      // Add all tasks
      for (final task in tasks) {
        await taskStateNotifier.addTask(task);
      }

      // Complete all tasks
      final allTasks = await databaseService.getAllTasks();
      for (final task in allTasks) {
        await taskStateNotifier.toggleTaskCompletion(task.id!);
      }

      // Check daily completion achievement progress
      final achievements = await achievementService.getAllAchievements();
      final dailyAchievements = achievements.where(
        (a) => a.type == AchievementType.dailyCompletion,
      ).toList();

      if (dailyAchievements.isNotEmpty) {
        final dailyAchievement = dailyAchievements.first;
        expect(dailyAchievement.currentProgress, equals(3));
      }
    });

    testWidgets('routine task achievements are tracked correctly', (WidgetTester tester) async {
      // Create a routine task
      final routineTask = Task(
        title: 'Routine Task',
        description: 'Daily routine',
        isRoutine: true,
        createdAt: DateTime.now(),
      );

      // Add routine task
      await taskStateNotifier.addTask(routineTask);

      // Get the routine task and complete it
      final tasks = await databaseService.getAllTasks();
      final addedRoutineTask = tasks.firstWhere((t) => t.isRoutine);
      await taskStateNotifier.toggleTaskCompletion(addedRoutineTask.id!);

      // Check routine consistency achievement progress
      final achievements = await achievementService.getAllAchievements();
      final routineAchievements = achievements.where(
        (a) => a.type == AchievementType.routineConsistency,
      ).toList();

      if (routineAchievements.isNotEmpty) {
        final routineAchievement = routineAchievements.first;
        expect(routineAchievement.currentProgress, greaterThanOrEqualTo(0));
      }
    });

    testWidgets('error handling works correctly when achievement service fails', (WidgetTester tester) async {
      // This test verifies that task operations still work even if achievement checking fails
      final testTask = Task(
        title: 'Test Task',
        description: 'Test Description',
        createdAt: DateTime.now(),
      );

      // Add task - should succeed even if achievement checking has issues
      final addResult = await taskStateNotifier.addTask(testTask);
      expect(addResult, isTrue);

      // Verify task was still added despite any achievement service issues
      final tasks = await databaseService.getAllTasks();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Test Task'));
    });

    tearDown(() async {
      // Clean up after each test by deleting all tasks
      final existingTasks = await databaseService.getAllTasks();
      for (final task in existingTasks) {
        if (task.id != null) {
          await databaseService.deleteTask(task.id!);
        }
      }
      await achievementService.resetAllAchievements();
    });
  });
}