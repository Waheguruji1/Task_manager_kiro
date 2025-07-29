import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../utils/theme.dart';
import 'achievement_widget.dart';

/// Example widget demonstrating the AchievementWidget with sample data
/// 
/// This widget shows various achievement states for testing and demonstration
class AchievementExample extends StatelessWidget {
  const AchievementExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earned Achievements',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            ..._buildEarnedAchievements(),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Unearned Achievements',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            ..._buildUnearnedAchievements(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEarnedAchievements() {
    final earnedAchievements = [
      Achievement(
        id: 'first_task',
        title: 'First Task',
        description: 'Complete your first task',
        icon: Icons.star,
        type: AchievementType.firstTime,
        targetValue: 1,
        isEarned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 5)),
        currentProgress: 1,
      ),
      Achievement(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Complete tasks for 7 consecutive days',
        icon: Icons.local_fire_department,
        type: AchievementType.streak,
        targetValue: 7,
        isEarned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 2)),
        currentProgress: 7,
      ),
    ];

    return earnedAchievements
        .map((achievement) => AchievementWidget(
              achievement: achievement,
              isEarned: true,
            ))
        .toList();
  }

  List<Widget> _buildUnearnedAchievements() {
    final unearnedAchievements = [
      Achievement(
        id: 'month_master',
        title: 'Month Master',
        description: 'Complete tasks for 30 consecutive days',
        icon: Icons.emoji_events,
        type: AchievementType.streak,
        targetValue: 30,
        isEarned: false,
        currentProgress: 12,
      ),
      Achievement(
        id: 'routine_champion',
        title: 'Routine Champion',
        description: 'Complete all routine tasks for 7 consecutive days',
        icon: Icons.repeat,
        type: AchievementType.routineConsistency,
        targetValue: 7,
        isEarned: false,
        currentProgress: 3,
      ),
      Achievement(
        id: 'task_tornado',
        title: 'Task Tornado',
        description: 'Complete 20 tasks in a single day',
        icon: Icons.flash_on,
        type: AchievementType.dailyCompletion,
        targetValue: 20,
        isEarned: false,
        currentProgress: 8,
      ),
    ];

    return unearnedAchievements
        .map((achievement) => AchievementWidget(
              achievement: achievement,
              isEarned: false,
            ))
        .toList();
  }
}