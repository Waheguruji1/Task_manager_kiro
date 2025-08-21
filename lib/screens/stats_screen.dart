import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';
import '../providers/providers.dart';
import '../models/task.dart';

/// Stats Screen Widget - Redesigned with focused data display
/// 
/// Shows only essential statistics: weekly completed tasks, today's tasks,
/// completion percentage with modern progress bar, and monthly heatmap
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  /// Calculate focused statistics
  Map<String, dynamic> _calculateFocusedStats(List<Task> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

    // Today's tasks
    final todayTasks = allTasks.where((task) {
      final taskDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      return taskDate.isAtSameMomentAs(today);
    }).toList();

    final todayCompleted = todayTasks.where((task) => task.isCompleted).length;
    final todayUncompleted = todayTasks.length - todayCompleted;

    // This week's completed tasks
    final weeklyCompleted = allTasks.where((task) {
      if (!task.isCompleted || task.completedAt == null) return false;
      final completedDate = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      return completedDate.isAfter(thisWeekStart.subtract(const Duration(days: 1))) &&
             completedDate.isBefore(today.add(const Duration(days: 1)));
    }).length;

    // Overall completion percentage
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((task) => task.isCompleted).length;
    final completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

    return {
      'todayCompleted': todayCompleted,
      'todayUncompleted': todayUncompleted,
      'weeklyCompleted': weeklyCompleted,
      'completionPercentage': completionPercentage,
    };
  }

  /// Get progress bar color based on completion percentage
  Color _getProgressColor(double percentage) {
    if (percentage >= 70) {
      return Colors.green;
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Build modern stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            value,
            style: AppTheme.headingLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText,
              fontSize: 32,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build modern boxy progress bar
  Widget _buildProgressBar({
    required String title,
    required double percentage,
  }) {
    final color = _getProgressColor(percentage);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
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
                  color: AppTheme.primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toInt()}%',
                  style: AppTheme.bodyLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build month selector
  Widget _buildMonthSelector() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Heatmap',
            style: AppTheme.headingMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Month selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _selectedMonth;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMonth = month;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: AppTheme.spacingS),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.greyPrimary 
                          : AppTheme.greyLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      months[index],
                      style: AppTheme.bodyMedium.copyWith(
                        color: isSelected 
                            ? AppTheme.primaryText 
                            : AppTheme.secondaryText,
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Simple heatmap placeholder (you can implement actual heatmap here)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_view_month,
                    size: 32,
                    color: AppTheme.secondaryText,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Heatmap for ${months[_selectedMonth - 1]} $_selectedYear',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    final stats = _calculateFocusedStats(tasks);
                    
                    return Column(
                      children: [
                        // Weekly and Today's Stats
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          child: Column(
                            children: [
                              _buildStatCard(
                                title: 'Completed This Week',
                                value: '${stats['weeklyCompleted']}',
                                icon: Icons.calendar_view_week,
                                color: AppTheme.greyPrimary,
                                subtitle: 'tasks completed',
                              ),
                              
                              const SizedBox(height: AppTheme.spacingM),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Completed Today',
                                      value: '${stats['todayCompleted']}',
                                      icon: Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingM),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Remaining Today',
                                      value: '${stats['todayUncompleted']}',
                                      icon: Icons.pending,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        // Progress Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          child: _buildProgressBar(
                            title: 'Overall Completion',
                            percentage: stats['completionPercentage'],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        // Heatmap Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          child: _buildMonthSelector(),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingXL),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
                      ),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingXL),
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
                            onPressed: () {
                              ref.invalidate(allTasksProvider);
                            },
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