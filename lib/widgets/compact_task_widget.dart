import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../utils/theme.dart';

import '../utils/responsive.dart';
import '../providers/providers.dart';
import 'task_item.dart';
import 'add_task_dialog.dart';

/// Compact Task Widget
/// 
/// A collapsible task container for the home screen that shows the latest tasks
/// with expand/collapse functionality and all task management features.
class CompactTaskWidget extends ConsumerStatefulWidget {
  /// Title for the task widget
  final String title;
  
  /// Whether to show everyday tasks or routine tasks
  final bool showRoutineTasks;
  
  /// Maximum number of tasks to show when collapsed
  final int maxTasksWhenCollapsed;
  
  /// Callback for task operations
  final Function(Task)? onTaskToggle;
  final Function(Task)? onTaskEdit;
  final Function(Task)? onTaskDelete;
  final VoidCallback? onAddTask;

  const CompactTaskWidget({
    super.key,
    required this.title,
    this.showRoutineTasks = false,
    this.maxTasksWhenCollapsed = 4,
    this.onTaskToggle,
    this.onTaskEdit,
    this.onTaskDelete,
    this.onAddTask,
  });

  @override
  ConsumerState<CompactTaskWidget> createState() => _CompactTaskWidgetState();
}

class _CompactTaskWidgetState extends ConsumerState<CompactTaskWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Toggle expand/collapse state
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// Handle add task
  Future<void> _handleAddTask() async {
    if (widget.onAddTask != null) {
      widget.onAddTask!();
      return;
    }

    // Default add task behavior
    final result = await showAddTaskDialog(
      context,
      isRoutineTask: widget.showRoutineTasks,
      onTaskSaved: () {
        // Refresh tasks
        ref.invalidate(everydayTasksProvider);
        ref.invalidate(routineTasksProvider);
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully!'),
          backgroundColor: AppTheme.greyPrimary,
        ),
      );
    }
  }

  /// Build the header with title and add button
  Widget _buildHeader() {
    final responsivePadding = ResponsiveUtils.getScreenPadding(context);
    final fontMultiplier = ResponsiveUtils.getFontSizeMultiplier(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        responsivePadding.horizontal / 2,
        AppTheme.spacingM,
        responsivePadding.horizontal / 2,
        AppTheme.spacingS,
      ),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Text(
              widget.title,
              style: AppTheme.headingMedium.copyWith(
                fontSize: 20 * fontMultiplier,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Add task button
          Material(
            color: AppTheme.greyPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
            child: InkWell(
              onTap: _handleAddTask,
              borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
              splashColor: AppTheme.greyPrimary.withValues(alpha: 0.2),
              highlightColor: AppTheme.greyPrimary.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                child: const Icon(
                  Icons.add,
                  color: AppTheme.greyPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the task list
  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    // Determine how many tasks to show
    final tasksToShow = _isExpanded 
        ? tasks 
        : tasks.take(widget.maxTasksWhenCollapsed).toList();
    
    final hasMoreTasks = tasks.length > widget.maxTasksWhenCollapsed;

    return Column(
      children: [
        // Task list
        Container(
          constraints: BoxConstraints(
            maxHeight: _isExpanded 
                ? ResponsiveUtils.isSmallScreen(context) ? 400 : 500
                : (widget.maxTasksWhenCollapsed * 80.0), // Approximate height per task
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: _isExpanded 
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: tasksToShow.length,
            itemBuilder: (context, index) {
              final task = tasksToShow[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
                child: TaskItem(
                  key: ValueKey('compact_task_${task.id}'),
                  task: task,
                  onToggle: (bool? value) => widget.onTaskToggle?.call(task),
                  onEdit: () => widget.onTaskEdit?.call(task),
                  onDelete: () => widget.onTaskDelete?.call(task),
                ),
              );
            },
          ),
        ),
        
        // Show more/less button
        if (hasMoreTasks)
          _buildExpandCollapseButton(tasks.length),
      ],
    );
  }

  /// Build expand/collapse button
  Widget _buildExpandCollapseButton(int totalTasks) {
    final remainingTasks = totalTasks - widget.maxTasksWhenCollapsed;
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
          splashColor: AppTheme.greyPrimary.withValues(alpha: 0.1),
          highlightColor: AppTheme.greyPrimary.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded 
                      ? 'Show Less'
                      : 'Show More ($remainingTasks more)',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.greyPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingXS),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.greyPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.greyPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
            ),
            child: const Icon(
              Icons.task_alt,
              size: 32,
              color: AppTheme.greyPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            widget.showRoutineTasks 
                ? 'No routine tasks yet'
                : 'No tasks yet',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Tap the + button to add your first task',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Failed to load tasks',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            error,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.greyPrimary,
              foregroundColor: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getScreenPadding(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);

    // Watch the appropriate task provider
    final tasksAsync = widget.showRoutineTasks
        ? ref.watch(routineTasksProvider)
        : ref.watch(everydayTasksProvider);

    return Center(
      child: Container(
        width: contentWidth,
        margin: EdgeInsets.fromLTRB(
          responsivePadding.horizontal / 2,
          AppTheme.spacingS,
          responsivePadding.horizontal / 2,
          AppTheme.spacingM,
        ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            
            // Content
            tasksAsync.when(
              data: (tasks) => _buildTaskList(tasks),
              loading: () => _buildLoadingState(),
              error: (error, _) => _buildErrorState(
                error.toString(),
                () {
                  if (widget.showRoutineTasks) {
                    ref.invalidate(routineTasksProvider);
                  } else {
                    ref.invalidate(everydayTasksProvider);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}