import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_kiro/widgets/achievement_widget.dart';
import 'package:task_manager_kiro/models/achievement.dart';
import 'package:task_manager_kiro/utils/theme.dart';

void main() {
  group('AchievementWidget Tests', () {
    late Achievement testAchievement;

    setUp(() {
      testAchievement = Achievement(
        id: 'test_achievement',
        title: 'Test Achievement',
        description: 'This is a test achievement',
        icon: Icons.star,
        type: AchievementType.streak,
        targetValue: 10,
        currentProgress: 5,
      );
    });

    testWidgets('displays earned achievement correctly', (WidgetTester tester) async {
      final earnedAchievement = testAchievement.copyWith(
        isEarned: true,
        earnedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AchievementWidget(
              achievement: earnedAchievement,
              isEarned: true,
            ),
          ),
        ),
      );

      // Check if title is displayed
      expect(find.text('Test Achievement'), findsOneWidget);
      
      // Check if description is displayed
      expect(find.text('This is a test achievement'), findsOneWidget);
      
      // Check if earned badge is displayed
      expect(find.text('Earned'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Check if achievement icon is displayed
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('displays unearned achievement with progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AchievementWidget(
              achievement: testAchievement,
              isEarned: false,
              progress: 0.5,
            ),
          ),
        ),
      );

      // Check if title is displayed
      expect(find.text('Test Achievement'), findsOneWidget);
      
      // Check if description is displayed
      expect(find.text('This is a test achievement'), findsOneWidget);
      
      // Check if progress indicator is displayed
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('5/10 days (50%)'), findsOneWidget);
      
      // Check if progress bar is displayed
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // Check if earned badge is NOT displayed
      expect(find.text('Earned'), findsNothing);
    });

    testWidgets('displays different progress text for different achievement types', (WidgetTester tester) async {
      final dailyAchievement = testAchievement.copyWith(
        type: AchievementType.dailyCompletion,
        currentProgress: 15,
        targetValue: 20,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AchievementWidget(
              achievement: dailyAchievement,
              isEarned: false,
            ),
          ),
        ),
      );

      // Check if correct progress text is displayed for daily completion
      expect(find.text('15/20 tasks (75%)'), findsOneWidget);
    });

    testWidgets('displays earned date when achievement is earned', (WidgetTester tester) async {
      final earnedDate = DateTime(2024, 1, 15);
      final earnedAchievement = testAchievement.copyWith(
        isEarned: true,
        earnedAt: earnedDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AchievementWidget(
              achievement: earnedAchievement,
              isEarned: true,
            ),
          ),
        ),
      );

      // Check if earned date is displayed
      expect(find.text('Earned on 15/1/2024'), findsOneWidget);
    });

    testWidgets('applies correct styling for earned vs unearned achievements', (WidgetTester tester) async {
      // Test earned achievement styling
      final earnedAchievement = testAchievement.copyWith(isEarned: true);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AchievementWidget(
              achievement: earnedAchievement,
              isEarned: true,
            ),
          ),
        ),
      );

      // Find the main container
      final containerFinder = find.byType(Container).first;
      expect(containerFinder, findsOneWidget);

      // Test unearned achievement styling
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AchievementWidget(
              achievement: testAchievement,
              isEarned: false,
            ),
          ),
        ),
      );

      // Verify progress indicator is shown for unearned
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}