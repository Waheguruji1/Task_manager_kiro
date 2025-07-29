import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';

import '../utils/responsive.dart';
import '../providers/providers.dart';
import '../models/task.dart';

/// Stats Screen Widget
/// 
/// Displays task statistics and productivity insights
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  /// Calculate task statistics
  Map<String, dynamic> _calculateStats(List<Task> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));

    // Basic counts
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((task) => task.isCompleted).length;
    final routineTasks = allTasks.where((task) => task.isRoutine).length;
    final everydayTasks = allTasks.where((task) => !task.isRoutine).length;

    // Time-based stats
    final todayTasks = allTasks.where((task) {
      final taskDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      return taskDate.isAtSameMomentAs(today);
    }).length;

    final thisWeekTasks = allTasks.where((task) {
      final taskDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      return taskDate.isAfter(thisWeek.subtract(const Duration(days: 1)));
    }).length;

    final thisMonthTasks = allTasks.where((task) {
      return task.createdAt.year == now.year && task.createdAt.month == now.month;
    }).length;

    // Completion stats
    final completedToday = allTasks.where((task) {
      if (!task.isCompleted || task.completedAt == null) return false;
      final completedDate = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      return completedDate.isAtSameMomentAs(today);
    }).length;

    final completedThisWeek = allTasks.where((task) {
      if (!task.isCompleted || task.completedAt == null) return false;
      final completedDate = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      return completedDate.isAfter(thisWeek.subtract(const Duration(days: 1)));
    }).length;

    // Calculate completion rate
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'routineTasks': routineTasks,
      'everydayTasks': everydayTasks,
      'todayTasks': todayTasks,
      'thisWeekTasks': thisWeekTasks,
      'thisMonthTasks': thisMonthTasks,
      'completedToday': completedToday,
      'completedThisWeek': completedThisWeek,
      'completionRate': completionRate,
    };
  }

  /// Build stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: Border.all(color: AppTheme.borderWhite),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            value,
            style: AppTheme.headingLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              subtitle,
              style: AppTheme.caption.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build progress indicator
  Widget _buildProgressIndicator({
    required String title,
    required double progress,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: Border.all(color: AppTheme.borderWhite),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.borderWhite,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksAsync = ref.watch(allTasksProvider);
    final responsivePadding = ResponsiveUtils.getScreenPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsivePadding.horizontal / 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: AppTheme.headingLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Your productivity insights',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Content
                allTasksAsync.when(
                  data: (tasks) {
                    final stats = _calculateStats(tasks);
                    
                    return Column(
                      children: [
                        // Overview Stats
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: AppTheme.spacingM,
                          mainAxisSpacing: AppTheme.spacingM,
                          childAspectRatio: 1.2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          children: [
                            _buildStatCard(
                              title: 'Total Tasks',
                              value: '${stats['totalTasks']}',
                              icon: Icons.task_alt,
                              color: AppTheme.greyPrimary,
                            ),
                            _buildStatCard(
                              title: 'Completed',
                              value: '${stats['completedTasks']}',
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              title: 'Routine Tasks',
                              value: '${stats['routineTasks']}',
                              icon: Icons.repeat,
                              color: AppTheme.purplePrimary,
                            ),
                            _buildStatCard(
                              title: 'Today',
                              value: '${stats['completedToday']}',
                              icon: Icons.today,
                              color: Colors.blue,
                              subtitle: 'completed today',
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        // Progress Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress',
                                style: AppTheme.headingMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              _buildProgressIndicator(
                                title: 'Overall Completion',
                                progress: stats['completionRate'] / 100,
                                color: Colors.green,
                                label: '${stats['completionRate'].toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        // Time-based Stats
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activity',
                                style: AppTheme.headingMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'This Week',
                                      value: '${stats['completedThisWeek']}',
                                      icon: Icons.date_range,
                                      color: Colors.orange,
                                      subtitle: 'completed',
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingM),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'This Month',
                                      value: '${stats['thisMonthTasks']}',
                                      icon: Icons.calendar_month,
                                      color: Colors.purple,
                                      subtitle: 'created',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppTheme.spacingXL),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
                      ),
                    ),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Failed to load statistics',
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(allTasksProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.greyPrimary,
                              foregroundColor: AppTheme.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}