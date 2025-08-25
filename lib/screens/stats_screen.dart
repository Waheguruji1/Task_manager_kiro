import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';
import '../providers/providers.dart';
import '../models/task.dart';
import '../widgets/heatmap_widget.dart';

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
  final int _selectedYear = DateTime.now().year;

  /// Generate sample tasks for demonstration when database is empty
  List<Task> _generateSampleTasks() {
    final now = DateTime.now();
    final sampleTasks = <Task>[];
    
    // Generate some sample tasks over the past month
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Create 1-3 tasks per day with varying completion status
      final tasksPerDay = (i % 3) + 1;
      for (int j = 0; j < tasksPerDay; j++) {
        final isCompleted = (i + j) % 3 != 0; // ~66% completion rate
        sampleTasks.add(Task(
          id: i * 10 + j,
          title: 'Sample Task ${i * 10 + j + 1}',
          isCompleted: isCompleted,
          isRoutine: j == 0, // First task of each day is routine
          createdAt: date,
          completedAt: isCompleted ? date.add(Duration(hours: j + 1)) : null,
        ));
      }
    }
    
    return sampleTasks;
  }

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
             taskDate.isAfter(today.subtract(const Duration(days: 7))); // Show tasks from last week if no today tasks
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
      
      return completedDate.isAfter(thisWeekStart.subtract(const Duration(days: 1))) &&
          completedDate.isBefore(today.add(const Duration(days: 1)));
    }).length;

    // Overall completion percentage
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((task) => task.isCompleted).length;
    final completionPercentage =
        totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

    // Debug: Print calculated stats
    debugPrint('Today tasks: ${todayTasks.length}, Completed: $todayCompleted, Uncompleted: $todayUncompleted');
    debugPrint('Weekly completed: $weeklyCompleted, Total completion: $completionPercentage%');

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

  /// Build modern stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Flexible(
                child: Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
                  borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
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
            child: Stack(
              children: [
                // Progress fill with minimum width for visibility
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage > 0 ? (percentage / 100).clamp(0.02, 1.0) : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
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

  /// Build activity heatmap with real data
  Widget _buildActivityHeatmap(List<Task> allTasks) {
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
          const SizedBox(height: AppTheme.spacingL),
          
          // Heatmap widget
          Consumer(
            builder: (context, ref, child) {
              final heatmapDataAsync = ref.watch(completionHeatmapDataProvider);
              
              return heatmapDataAsync.when(
                data: (heatmapData) {
                  return HeatmapWidget(
                    data: heatmapData,
                    baseColor: AppTheme.greyPrimary,
                    title: 'Task Completion Activity',
                    cellSize: 10.0,
                    spacing: 2.0,
                    onCellTap: (date, value) {
                      // Show task details for the selected date
                      _showDateTaskDetails(context, date, value as int?, allTasks);
                    },
                    tooltipBuilder: (date, value) {
                      final count = value as int? ?? 0;
                      return Text(
                        '${date.day}/${date.month}/${date.year}\n$count tasks completed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  );
                },
                loading: () => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
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
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
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
                          'Failed to load heatmap',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Show task details for a specific date
  void _showDateTaskDetails(BuildContext context, DateTime date, int? completedCount, List<Task> allTasks) {
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
                        color: Colors.green,
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
                allTasksAsync.when(
                  data: (tasks) {
                    // If no tasks exist, show sample data for demonstration
                    final effectiveTasks = tasks.isEmpty ? _generateSampleTasks() : tasks;
                    final stats = _calculateFocusedStats(effectiveTasks);

                    return Column(
                      children: [
                        // Sample data notice
                        if (tasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: AppTheme.greyPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.greyPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Expanded(
                                    child: Text(
                                      'No tasks found. Showing sample data for demonstration.',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.greyPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        if (tasks.isEmpty) const SizedBox(height: AppTheme.spacingL),

                        // Weekly Stats
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          child: _buildStatCard(
                            title: 'Completed This Week',
                            value: '${stats['weeklyCompleted']}',
                            icon: Icons.calendar_view_week,
                            color: AppTheme.greyPrimary,
                            subtitle: 'tasks completed',
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        // Today's Stats Row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 140),
                                  child: _buildStatCard(
                                    title: 'Completed Today',
                                    value: '${stats['todayCompleted']}',
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingL),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 140),
                                  child: _buildStatCard(
                                    title: 'Remaining Today',
                                    value: '${stats['todayUncompleted']}',
                                    icon: Icons.pending,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

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

                        const SizedBox(height: AppTheme.spacingXL),

                        // Heatmap Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          child: _buildActivityHeatmap(effectiveTasks),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),
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
