import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_kiro/screens/stats_screen.dart';
import 'package:task_manager_kiro/models/task.dart';
import 'package:task_manager_kiro/models/achievement.dart';
import 'package:task_manager_kiro/providers/providers.dart';
import 'package:task_manager_kiro/utils/theme.dart';

void main() {
  group('Enhanced Stats Screen Tests', () {
    testWidgets('should display heatmap sections and achievements', (WidgetTester tester) async {
      // Create mock data
      final mockTasks = [
        Task(
          id: 1,
          title: 'Test Task 1',
          isCompleted: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Task(
          id: 2,
          title: 'Test Task 2',
          isCompleted: true,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        ),
      ];

      final mockAchievements = [
        Achievement(
          id: 'first_task',
          title: 'First Task',
          description: 'Complete your first task',
          icon: Icons.star,
          type: AchievementType.firstTime,
          targetValue: 1,
          isEarned: true,
          earnedAt: DateTime.now(),
          currentProgress: 1,
        ),
        Achievement(
          id: 'week_warrior',
          title: 'Week Warrior',
          description: 'Complete tasks for 7 consecutive days',
          icon: Icons.local_fire_department,
          type: AchievementType.streak,
          targetValue: 7,
          isEarned: false,
          currentProgress: 3,
        ),
      ];

      // Create a container with overridden providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTasksProvider.overrideWith((ref) => Future.value(mockTasks)),
            allAchievementsProvider.overrideWith((ref) => Future.value(mockAchievements)),
            completionHeatmapDataProvider.overrideWith((ref) => Future.value({
              DateTime.now(): 2,
              DateTime.now().subtract(const Duration(days: 1)): 1,
            })),
            creationCompletionHeatmapDataProvider.overrideWith((ref) => Future.value({
              DateTime.now(): {'created': 1, 'completed': 2},
              DateTime.now().subtract(const Duration(days: 1)): {'created': 1, 'completed': 1},
            })),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const StatsScreen(),
          ),
        ),
      );

      // Wait for the widget to build and data to load
      await tester.pumpAndSettle();

      // Verify that the screen displays the expected sections
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Task Completion Activity'), findsOneWidget);
      expect(find.text('Task Creation vs Completion'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);

      // Verify achievement display
      expect(find.text('First Task'), findsOneWidget);
      expect(find.text('Week Warrior'), findsOneWidget);
      expect(find.text('Earned (1)'), findsOneWidget);
      expect(find.text('In Progress (1)'), findsOneWidget);
    });

    testWidgets('should handle loading states correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTasksProvider.overrideWith((ref) => Future.delayed(
              const Duration(seconds: 1),
              () => <Task>[],
            )),
            allAchievementsProvider.overrideWith((ref) => Future.delayed(
              const Duration(seconds: 1),
              () => <Achievement>[],
            )),
            completionHeatmapDataProvider.overrideWith((ref) => Future.delayed(
              const Duration(seconds: 1),
              () => <DateTime, int>{},
            )),
            creationCompletionHeatmapDataProvider.overrideWith((ref) => Future.delayed(
              const Duration(seconds: 1),
              () => <DateTime, Map<String, int>>{},
            )),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const StatsScreen(),
          ),
        ),
      );

      // Verify loading indicators are shown
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify content is displayed after loading
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('should handle error states correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTasksProvider.overrideWith((ref) => Future.error('Test error')),
            allAchievementsProvider.overrideWith((ref) => Future.error('Test error')),
            completionHeatmapDataProvider.overrideWith((ref) => Future.error('Test error')),
            creationCompletionHeatmapDataProvider.overrideWith((ref) => Future.error('Test error')),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const StatsScreen(),
          ),
        ),
      );

      // Wait for the widget to build and errors to be handled
      await tester.pumpAndSettle();

      // Verify error states are displayed (check for error icons and retry buttons)
      expect(find.byIcon(Icons.error_outline), findsWidgets);
      expect(find.text('Retry'), findsWidgets);
    });

    testWidgets('should display empty achievements state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allTasksProvider.overrideWith((ref) => Future.value(<Task>[])),
            allAchievementsProvider.overrideWith((ref) => Future.value(<Achievement>[])),
            completionHeatmapDataProvider.overrideWith((ref) => Future.value(<DateTime, int>{})),
            creationCompletionHeatmapDataProvider.overrideWith((ref) => Future.value(<DateTime, Map<String, int>>{})),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const StatsScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify empty achievements state
      expect(find.text('No achievements yet'), findsOneWidget);
      expect(find.text('Complete tasks to unlock achievements!'), findsOneWidget);
    });
  });
}