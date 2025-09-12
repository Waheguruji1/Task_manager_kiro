import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/yearly_data_cleanup_service.dart';
import '../lib/services/database_service.dart';
import '../lib/models/task.dart';
import '../lib/models/achievement.dart';

void main() {
  group('YearlyDataCleanupService Tests', () {
    late YearlyDataCleanupService cleanupService;
    late DatabaseService databaseService;

    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      // Initialize database service
      databaseService = await DatabaseService.getInstance();
      await databaseService.initialize();
      
      // Initialize cleanup service
      cleanupService = YearlyDataCleanupService(databaseService);
    });

    tearDownAll(() async {
      // Clean up database
      await databaseService.close();
    });

    setUp(() async {
      // Clear all data before each test
      await databaseService.deleteAllTasks();
      await databaseService.database.resetAllAchievements();
      
      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should detect when cleanup is needed for new year', () async {
      // Arrange - no previous cleanup recorded
      
      // Act
      final result = await cleanupService.performCleanupIfNeeded();
      
      // Assert
      expect(result, isTrue, reason: 'Should perform cleanup when no previous cleanup recorded');
    });

    test('should not perform cleanup if already done for current year', () async {
      // Arrange - perform cleanup once
      await cleanupService.performCleanupIfNeeded();
      
      // Act - try to perform cleanup again
      final result = await cleanupService.performCleanupIfNeeded();
      
      // Assert
      expect(result, isFalse, reason: 'Should not perform cleanup twice in same year');
    });

    test('should reset achievement progress during cleanup', () async {
      // Arrange - create some achievements with progress
      final achievements = await databaseService.getAllAchievements();
      if (achievements.isNotEmpty) {
        // Set some progress on first achievement
        await databaseService.updateAchievementProgress(achievements.first.id, 5);
        await databaseService.earnAchievement(achievements.first.id);
      }
      
      // Act
      await cleanupService.performCleanupIfNeeded();
      
      // Assert
      final updatedAchievements = await databaseService.getAllAchievements();
      for (final achievement in updatedAchievements) {
        expect(achievement.currentProgress, equals(0), 
               reason: 'Achievement progress should be reset to 0');
        expect(achievement.isEarned, isFalse, 
               reason: 'Achievement should be marked as unearned');
      }
    });

    test('should preserve task data during cleanup', () async {
      // Arrange - create some test tasks
      final testTask = Task(
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: true,
        isRoutine: false,
        createdAt: DateTime(2023, 1, 1), // Previous year
        completedAt: DateTime(2023, 1, 2),
        priority: TaskPriority.high,
      );
      
      await databaseService.createTask(testTask);
      
      // Act
      await cleanupService.performCleanupIfNeeded();
      
      // Assert
      final tasks = await databaseService.getAllTasks();
      expect(tasks.length, equals(1), reason: 'Task data should be preserved');
      expect(tasks.first.title, equals('Test Task'));
    });

    test('should provide cleanup information', () async {
      // Arrange - create some test data
      final testTask = Task(
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        isRoutine: false,
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
      );
      
      await databaseService.createTask(testTask);
      
      // Act
      final info = await cleanupService.getCleanupInfo();
      
      // Assert
      expect(info, isA<Map<String, dynamic>>());
      expect(info.containsKey('currentYear'), isTrue);
      expect(info.containsKey('totalTasks'), isTrue);
      expect(info.containsKey('totalAchievements'), isTrue);
      expect(info['currentYear'], equals(DateTime.now().year));
    });

    test('should handle cleanup errors gracefully', () async {
      // Arrange - close database to simulate error
      await databaseService.close();
      
      // Act & Assert - should not throw
      final result = await cleanupService.performCleanupIfNeeded();
      expect(result, isFalse, reason: 'Should return false on error');
      
      // Restore database for other tests
      databaseService = await DatabaseService.getInstance();
      await databaseService.initialize();
      cleanupService = YearlyDataCleanupService(databaseService);
    });

    test('should force cleanup regardless of year', () async {
      // Arrange - perform normal cleanup first
      await cleanupService.performCleanupIfNeeded();
      
      // Act - force cleanup
      final result = await cleanupService.forceCleanup();
      
      // Assert
      expect(result, isTrue, reason: 'Force cleanup should always succeed');
    });

    test('should return correct data retention cutoff', () async {
      // Act
      final cutoff = cleanupService.getDataRetentionCutoff();
      
      // Assert
      final expectedCutoff = DateTime(DateTime.now().year, 1, 1);
      expect(cutoff.year, equals(expectedCutoff.year));
      expect(cutoff.month, equals(expectedCutoff.month));
      expect(cutoff.day, equals(expectedCutoff.day));
    });
  });
}