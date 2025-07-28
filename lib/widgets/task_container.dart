import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../utils/error_handler.dart';
import '../utils/responsive.dart';
import 'task_item.dart';

/// Task container widget with rounded rectangular design and white border
/// 
/// This widget displays tasks for a specific date with a date header,
/// scrollable task list, and a plus icon for adding new tasks.
class TaskContainer extends StatelessWidget {
  /// The date for which tasks are displayed
  final DateTime date;
  
  /// List of tasks to display
  final List<Task> tasks;
  
  /// Callback when add task button is pressed
  final VoidCallback onAddTask;
  
  /// Callback when a task's completion status is toggled
  final Function(Task) onTaskToggle;
  
  /// Callback when a task edit is requested
  final Function(Task) onTaskEdit;
  
  /// Callback when a task deletion is requested
  final Function(Task) onTaskDelete;

  const TaskContainer({
    super.key,
    required this.date,
    required this.tasks,
    required this.onAddTask,
    required this.onTaskToggle,
    required this.onTaskEdit,
    required this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getScreenPadding(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    
    return Center(
      child: Container(
        width: contentWidth,
        margin: EdgeInsets.symmetric(
          horizontal: responsivePadding.horizontal / 2,
          vertical: AppTheme.containerMargin,
        ),
        decoration: AppTheme.taskContainerDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and add button
            _buildHeader(context),
            
            // Task list or empty state
            _buildTaskList(context),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with date and add task button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderWhite,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date display
          Text(
            _formatDate(date),
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryText,
            ),
          ),
          
          // Add task button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddTask,
              borderRadius: BorderRadius.circular(24),
              splashColor: AppTheme.greyPrimary.withValues(alpha: 0.2),
              highlightColor: AppTheme.greyPrimary.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingS + 2),
                decoration: AppTheme.plusIconDecoration,
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: AppTheme.primaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable task list or empty state
  Widget _buildTaskList(BuildContext context) {
    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    final containerHeight = ResponsiveUtils.getTaskContainerHeight(context);
    final responsiveSpacing = ResponsiveUtils.getSpacing(context, AppTheme.spacingM);

    return Container(
      constraints: BoxConstraints(
        maxHeight: containerHeight, // Responsive height based on screen size
      ),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          responsiveSpacing,
          AppTheme.spacingS,
          responsiveSpacing,
          responsiveSpacing,
        ),
        itemCount: tasks.length + 1, // +1 for bottom spacing
        itemBuilder: (context, index) {
          // Add extra spacing at the bottom for better scrolling experience
          if (index == tasks.length) {
            return const SizedBox(height: AppTheme.spacingS);
          }
          
          final task = tasks[index];
          return TaskItem(
            key: ValueKey(task.id ?? task.hashCode), // Provide unique key for performance
            task: task,
            onToggle: (value) => _safeCallback(() => onTaskToggle(task), 'toggle task'),
            onEdit: () => _safeCallback(() => onTaskEdit(task), 'edit task'),
            onDelete: () => _safeCallback(() => onTaskDelete(task), 'delete task'),
          );
        },
      ),
    );
  }

  /// Safely execute callback functions with error handling
  void _safeCallback(VoidCallback callback, String operation) {
    try {
      callback();
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'TaskContainer $operation',
        type: ErrorType.unknown,
      );
      // Don't rethrow as this would break the UI
      // The parent widget should handle the actual error display
    }
  }

  /// Builds the empty state when no tasks are available
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingXL,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.greyPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.borderWhite.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.task_alt_outlined,
              size: 32,
              color: AppTheme.greyPrimary.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          Text(
            'No tasks for today',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingS),
          
          Text(
            'Tap the + button to add your first task',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.disabledText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Formats the date for display in the header
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    
    // Check if it's today
    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      return 'Today';
    }
    
    // Check if it's yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day) {
      return 'Yesterday';
    }
    
    // Check if it's tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    if (tomorrow.year == date.year &&
        tomorrow.month == date.month &&
        tomorrow.day == date.day) {
      return 'Tomorrow';
    }
    
    // Format as day/month/year for other dates
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    
    return '$weekday, $month ${date.day}';
  }
}