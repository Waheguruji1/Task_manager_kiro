import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';
import '../providers/providers.dart';
import '../models/task.dart';
import '../widgets/heatmap_widget.dart';
import '../widgets/simple_month_selector.dart';
import '../services/data_cleanup_service.dart';

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
  // Month selector state (for future use)
  // int _selectedMonth = DateTime.now().month;
  // final int _selectedYear = DateTime.now().year;



  /// Calculate focused statistics
  Map<String, dynamic> _calculateFocusedStats(List<Task> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

    // Debug: Print task count
    debugPrint('Total tasks in database: ${allTasks.length}');

    // Today's tasks - be more inclusive to show data
    final todayTasks = allTasks.where((task) {
      final taskDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      // Include tasks created today, or if no tasks today, include recent tasks
      return taskDate.isAtSameMomentAs(today) ||
          (allTasks.isEmpty && task.isRoutine) ||
          taskDate.isAfter(today.subtract(const Duration(
              days: 7))); // Show tasks from last week if no today tasks
    }).toList();

    final todayCompleted = todayTasks.where((task) => task.isCompleted).length;
    final todayUncompleted = todayTasks.length - todayCompleted;

    // This week's completed tasks (more flexible completion date handling)
    final weeklyCompleted = allTasks.where((task) {
      if (!task.isCompleted) return false;

      // Use completedAt if available, otherwise use createdAt for completed tasks
      final dateToCheck = task.completedAt ?? task.createdAt;
      final completedDate = DateTime(
        dateToCheck.year,
        dateToCheck.month,
        dateToCheck.day,
      );

      return completedDate
              .isAfter(thisWeekStart.subtract(const Duration(days: 1))) &&
          completedDate.isBefore(today.add(const Duration(days: 1)));
    }).length;

    // Overall completion percentage
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((task) => task.isCompleted).length;
    final completionPercentage =
        totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

    // Debug: Print calculated stats
    debugPrint(
        'Today tasks: ${todayTasks.length}, Completed: $todayCompleted, Uncompleted: $todayUncompleted');
    debugPrint(
        'Weekly completed: $weeklyCompleted, Total completion: $completionPercentage%');

    return {
      'todayCompleted': todayCompleted,
      'todayUncompleted': todayUncompleted,
      'weeklyCompleted': weeklyCompleted,
      'completionPercentage': completionPercentage.roundToDouble(),
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

  /// Build modern stat card with improved layout
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    bool isCompact = false,
  }) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(isCompact ? AppTheme.spacingM : AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                    isCompact ? AppTheme.spacingXS : AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isCompact ? 20 : 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  title,
                  style: (isCompact ? AppTheme.bodyMedium : AppTheme.bodyLarge)
                      .copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? AppTheme.spacingM : AppTheme.spacingL),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTheme.headingLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                  fontSize: isCompact ? 28 : 32,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: AppTheme.spacingS),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    subtitle,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Build modern progress bar with enhanced design
  Widget _buildProgressBar({
    required String title,
    required double percentage,
    String? subtitle,
  }) {
    final color = _getProgressColor(percentage);
    final progressText = _getProgressText(percentage);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText,
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
              ),
              const SizedBox(width: AppTheme.spacingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppTheme.buttonBorderRadius),
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

          // Progress bar with enhanced styling
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.greyLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Stack(
              children: [
                // Progress fill with smooth animation
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage > 0
                      ? (percentage / 100).clamp(0.02, 1.0)
                      : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Progress description
          Text(
            progressText,
            style: AppTheme.caption.copyWith(
              color: AppTheme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get descriptive text for progress percentage
  String _getProgressText(double percentage) {
    if (percentage >= 90) {
      return 'Excellent productivity! 🎉';
    } else if (percentage >= 70) {
      return 'Great job! Keep it up! 👏';
    } else if (percentage >= 50) {
      return 'Good progress, you\'re on track 📈';
    } else if (percentage >= 25) {
      return 'Room for improvement 💪';
    } else {
      return 'Let\'s get started! 🚀';
    }
  }

  /// Build quick stats summary widget
  Widget _buildQuickStatsSummary(Map<String, dynamic> stats) {
    final totalTasks =
        (stats['todayCompleted'] as int) + (stats['todayUncompleted'] as int);
    final completionRate = stats['completionPercentage'] as double;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.greyPrimary.withValues(alpha: 0.1),
            AppTheme.greyPrimary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 4),
        border: Border.all(
          color: AppTheme.greyPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Main stat
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Progress',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${stats['todayCompleted']}',
                        style: AppTheme.headingLarge.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                      TextSpan(
                        text: ' / $totalTasks',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: ' tasks',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Completion rate indicator
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: _getProgressColor(completionRate).withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppTheme.containerBorderRadius),
            ),
            child: Column(
              children: [
                Icon(
                  completionRate >= 70
                      ? Icons.trending_up
                      : completionRate >= 40
                          ? Icons.trending_flat
                          : Icons.trending_down,
                  color: _getProgressColor(completionRate),
                  size: 24,
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  '${completionRate.toInt()}%',
                  style: AppTheme.bodyMedium.copyWith(
                    color: _getProgressColor(completionRate),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build activity heatmap with enhanced design
  Widget _buildActivityHeatmap(List<Task> allTasks) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
        border: Border.all(
          color: AppTheme.greyPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.greyPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_view_month,
                  color: AppTheme.greyPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
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
                    Text(
                      'Tap on any day to see details',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Improved Heatmap widget with better UI
          Consumer(
            builder: (context, ref, child) {
              final heatmapDataAsync = ref.watch(completionHeatmapDataProvider);

              return heatmapDataAsync.when(
                data: (heatmapData) {
                  return Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
                      border: Border.all(
                        color: AppTheme.greyPrimary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_view_month,
                              color: AppTheme.greyPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              'Task Completion Activity',
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        
                        // Improved Heatmap
                        HeatmapWidget(
                          data: heatmapData,
                          baseColor: AppTheme.greyPrimary,
                          title: '',
                          cellSize: 12.0,
                          spacing: 3.0,
                          onCellTap: (date, value) {
                            _showDateTaskDetails(context, date, value as int?, allTasks);
                          },
                          tooltipBuilder: (date, value) {
                            final count = value as int? ?? 0;
                            return Container(
                              padding: const EdgeInsets.all(AppTheme.spacingS),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundDark,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.greyPrimary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${date.day}/${date.month}/${date.year}\n$count tasks completed',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.primaryText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: AppTheme.spacingS),
                        
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Less',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.secondaryText,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingS),
                            ...List.generate(5, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppTheme.greyPrimary.withValues(
                                    alpha: (index + 1) * 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                            const SizedBox(width: AppTheme.spacingS),
                            Text(
                              'More',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGrey,
                    borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
                    ),
                  ),
                ),
                error: (error, _) => Container(
                  height: 120,
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGrey,
                    borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 32,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          'Failed to load activity data',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        TextButton(
                          onPressed: () {
                            ref.invalidate(completionHeatmapDataProvider);
                          },
                          child: Text(
                            'Retry',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.greyPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Month selector for current year
          SimpleMonthSelector(
            selectedMonth: _selectedMonth,
            onMonthChanged: (month) {
              setState(() {
                _selectedMonth = month;
              });
            },
            currentYear: DateTime.now().year,
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Data management section
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrey,
              borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.storage,
                      color: AppTheme.greyPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      'Data Management',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Keep only current year data for better performance',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _cleanupOldData,
                    icon: const Icon(Icons.cleaning_services, size: 18),
                    label: const Text('Clean Old Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.greyPrimary,
                      foregroundColor: AppTheme.primaryText,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// Show task details for a specific date
  void _showDateTaskDetails(BuildContext context, DateTime date,
      int? completedCount, List<Task> allTasks) {
    final tasksForDate = allTasks.where((task) {
      if (!task.isCompleted || task.completedAt == null) return false;
      final taskDate = DateTime(
        task.completedAt!.year,
        task.completedAt!.month,
        task.completedAt!.day,
      );
      final selectedDate = DateTime(date.year, date.month, date.day);
      return taskDate.isAtSameMomentAs(selectedDate);
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceGrey,
        title: Text(
          'Tasks completed on ${date.day}/${date.month}/${date.year}',
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.primaryText,
          ),
        ),
        content: tasksForDate.isEmpty
            ? Text(
                'No tasks completed on this date',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.secondaryText,
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasksForDate.length,
                  itemBuilder: (context, index) {
                    final task = tasksForDate[index];
                    return ListTile(
                      leading: Icon(
                        Icons.check_circle,
                        color: AppTheme.greyPrimary,
                        size: 20,
                      ),
                      title: Text(
                        task.title,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryText,
                        ),
                      ),
                      subtitle: task.isRoutine
                          ? Text(
                              'Routine Task',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.greyPrimary,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.greyPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanupOldData() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      final cleanupService = DataCleanupService(databaseService);
      
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceGrey,
          title: Text(
            'Clean Old Data',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.primaryText),
          ),
          content: Text(
            'This will delete all tasks from previous years, keeping only ${DateTime.now().year} data. This action cannot be undone.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greyPrimary,
                foregroundColor: AppTheme.primaryText,
              ),
              child: const Text('Clean Data'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        await cleanupService.cleanupOldData();
        
        // Refresh providers
        ref.invalidate(allTasksProvider);
        ref.invalidate(completionHeatmapDataProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Old data cleaned successfully',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryText),
              ),
              backgroundColor: AppTheme.greyPrimary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to clean data: ${e.toString()}',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.secondaryText),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the task change notifier to ensure stats update when tasks change
    ref.watch(taskChangeNotifierProvider);

    // Watch the task state notifier for real-time updates
    final taskStateAsync = ref.watch(asyncTaskStateNotifierProvider);
    final responsivePadding = ResponsiveUtils.getOptimalMobilePadding(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsivePadding.horizontal,
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
                taskStateAsync.when(
                  data: (taskStateNotifier) {
                    final taskState = taskStateNotifier.currentState;
                    final tasks = [
                      ...taskState.everydayTasks,
                      ...taskState.routineTasks
                    ];

                    // Use actual tasks, don't generate sample data
                    final effectiveTasks = tasks;
                    final stats = _calculateFocusedStats(effectiveTasks);

                    return Column(
                      children: [
                        // Empty state notice
                        if (tasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingS,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingXL),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceGrey,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.containerBorderRadius + 2),
                                border: Border.all(
                                  color: AppTheme.greyPrimary.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    color: AppTheme.greyPrimary,
                                    size: 48,
                                  ),
                                  const SizedBox(height: AppTheme.spacingM),
                                  Text(
                                    'No Statistics Yet',
                                    style: AppTheme.headingMedium.copyWith(
                                      color: AppTheme.primaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  Text(
                                    'Start adding and completing tasks to see your productivity insights here.',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.secondaryText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppTheme.spacingL),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Navigate to home screen to add tasks
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.add_task),
                                    label: const Text('Add Your First Task'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.greyPrimary,
                                      foregroundColor: AppTheme.primaryText,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacingL,
                                        vertical: AppTheme.spacingM,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (tasks.isEmpty)
                          const SizedBox(height: AppTheme.spacingXL),

                        // Show stats only when there are tasks
                        if (tasks.isNotEmpty) ...[
                          // Quick Stats Summary
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                          ),
                          child: _buildQuickStatsSummary(stats),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Stats Grid - Column layout for better readability
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                          ),
                          child: Column(
                            children: [
                              // Weekly Stats - Full width
                              _buildStatCard(
                                title: 'Tasks Completed This Week',
                                value: '${stats['weeklyCompleted']}',
                                icon: Icons.calendar_view_week,
                                color: AppTheme.greyPrimary,
                                subtitle: 'tasks',
                              ),

                              const SizedBox(height: AppTheme.spacingL),

                              // Today's Stats - Side by side but with proper spacing
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Completed Today',
                                      value: '${stats['todayCompleted']}',
                                      icon: Icons.check_circle,
                                      color: Colors.green,
                                      isCompact: true,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingM),
                                  Expanded(
                                    child: _buildStatCard(
                                      title: 'Remaining Today',
                                      value: '${stats['todayUncompleted']}',
                                      icon: Icons.pending,
                                      color: Colors.orange,
                                      isCompact: true,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppTheme.spacingL),

                              // Routine Tasks Stats
                              _buildStatCard(
                                title: 'Active Routine Tasks',
                                value: '${taskState.routineTasks.length}',
                                icon: Icons.repeat,
                                color: Colors.blue,
                                subtitle: 'routines',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Progress Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                          ),
                          child: _buildProgressBar(
                            title: 'Overall Completion Rate',
                            percentage: stats['completionPercentage'],
                            subtitle: 'Based on all your tasks',
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Heatmap Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                          ),
                          child: _buildActivityHeatmap(effectiveTasks),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingXL),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
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
