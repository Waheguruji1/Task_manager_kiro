import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/modern_add_task_dialog.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/paginated_task_list.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../providers/providers.dart';
import 'package:intl/intl.dart';

/// Home Screen Widget
///
/// The main task management interface with tabbed organization for
/// everyday and routine tasks. Features personalized greeting,
/// custom AppBar with share functionality, and task loading/display logic.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  DateTime _lastCheckedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _initializeDailyTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Check for date changes when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _checkForDateChange();
    }
  }

  /// Check if date has changed and refresh tasks if needed
  void _checkForDateChange() {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(_lastCheckedDate.year, _lastCheckedDate.month, _lastCheckedDate.day);
    
    if (currentDate != lastDate) {
      _lastCheckedDate = now;
      // Refresh tasks when date changes
      ref.invalidate(taskStateStreamProvider);
      _initializeDailyTasks();
    }
  }

  /// Initialize daily routine tasks if needed
  Future<void> _initializeDailyTasks() async {
    try {
      final prefsService =
          await ref.read(asyncPreferencesServiceProvider.future);
      final dbService = await ref.read(asyncDatabaseServiceProvider.future);

      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';

      // Get the last reset date from SharedPreferences
      final lastResetDate = await prefsService.getLastResetDate();

      // If it's a new day, create daily routine task instances
      if (lastResetDate != todayString) {
        ErrorHandler.logError(
            'New day detected. Creating daily routine task instances...',
            context: 'Daily reset',
            type: ErrorType.unknown);

        final success = await dbService.createDailyRoutineTaskInstances();
        if (success) {
          // Save today's date as the last reset date
          await prefsService.setLastResetDate(todayString);
          ErrorHandler.logError(
              'Daily routine task instances created successfully for $todayString',
              context: 'Daily reset',
              type: ErrorType.unknown);
          
          // Refresh task state after creating new instances
          ref.invalidate(taskStateStreamProvider);
        } else {
          ErrorHandler.logError('Failed to create daily routine task instances',
              context: 'Daily reset', type: ErrorType.database);
        }
      }
    } catch (e) {
      ErrorHandler.logError(e,
          context: 'Check and reset daily tasks', type: ErrorType.database);
      // Don't throw error as this shouldn't prevent app from loading
    }
  }

  /// Handle task completion toggle
  Future<void> _onTaskToggle(Task task) async {
    if (task.id == null) return;

    try {
      final taskStateNotifier =
          await ref.read(asyncTaskStateNotifierProvider.future);
      final success = await taskStateNotifier.toggleTaskCompletion(task.id!);

      if (success) {
        // Show success message for completed tasks
        if (!task.isCompleted && mounted) {
          ErrorHandler.showSuccessSnackBar(
              context, AppStrings.taskCompletedSuccess);
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, AppStrings.errorUpdatingTask);
        }
      }
    } catch (e) {
      ErrorHandler.logError(e,
          context: 'Toggle task completion', type: ErrorType.database);
      if (mounted) {
        String errorMessage = AppStrings.errorUpdatingTask;
        if (e is AppException) {
          errorMessage = e.message;
        }
        ErrorHandler.showErrorSnackBar(context, errorMessage);
      }
    }
  }

  /// Handle task edit
  Future<void> _onTaskEdit(Task task) async {
    final result = await showModernEditTaskDialog(
      context,
      task: task,
      onTaskSaved: () {
        // No need to manually invalidate - TaskStateNotifier handles state updates automatically
      },
    );

    if (result == true && mounted) {
      ErrorHandler.showSuccessSnackBar(context, AppStrings.taskUpdatedSuccess);
    }
  }

  /// Handle task deletion
  Future<void> _onTaskDelete(Task task) async {
    if (task.id == null) return;

    // Show confirmation dialog
    final confirmed = await _showDeleteConfirmationDialog(task.title);
    if (!confirmed) return;

    // Show optimistic success message immediately
    if (mounted) {
      ErrorHandler.showSuccessSnackBar(
          context, AppStrings.taskDeletedSuccess);
    }

    try {
      final taskStateNotifier =
          await ref.read(asyncTaskStateNotifierProvider.future);
      bool success;

      // Check if this is a routine task template
      if (task.isRoutine && task.routineTaskId == null) {
        // This is a routine task template - delete the routine task and all its instances
        success =
            await taskStateNotifier.deleteRoutineTaskAndInstances(task.id!);
      } else {
        // This is either a regular everyday task or a routine task instance
        // Just delete this specific task
        success = await taskStateNotifier.deleteTask(task.id!);
      }

      // If deletion failed, show error (optimistic UI already showed success)
      if (!success && mounted) {
        ErrorHandler.showErrorSnackBar(context, 'Failed to delete task. Please try again.');
      }
    } catch (e) {
      ErrorHandler.logError(e,
          context: 'Delete task', type: ErrorType.database);
      if (mounted) {
        String errorMessage = AppStrings.errorDeletingTask;
        if (e is AppException) {
          errorMessage = e.message;
        }
        ErrorHandler.showErrorSnackBar(context, errorMessage);
      }
    }
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmationDialog(String taskTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTaskTitle),
        content: Text(AppStrings.deleteTaskMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(AppStrings.deleteButton),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Build tab bar - iOS Style
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.greyPrimary,
          borderRadius:
              BorderRadius.circular(AppTheme.containerBorderRadius - 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.primaryText,
        unselectedLabelColor: AppTheme.secondaryText,
        labelStyle: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        tabs: [
          Tab(
            child: Semantics(
              label: 'Everyday Tasks tab',
              hint: 'View your daily tasks',
              child: const Text('Everyday Tasks'),
            ),
          ),
          Tab(
            child: Semantics(
              label: 'Routine Tasks tab',
              hint: 'View your routine tasks',
              child: const Text('Routine Tasks'),
            ),
          ),
        ],
      ),
    );
  }

  /// Get date label for task container - always relative to current date
  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  /// Group tasks by date - dynamically based on current date relationship
  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final Map<DateTime, List<Task>> groupedTasks = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final task in tasks) {
      final taskCreatedDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );

      // Determine which date group this task should belong to
      DateTime groupDate;
      
      // If task was created today, group under today
      if (taskCreatedDate == today) {
        groupDate = today;
      } 
      // If task was created yesterday, group under yesterday
      else if (taskCreatedDate == today.subtract(const Duration(days: 1))) {
        groupDate = today.subtract(const Duration(days: 1));
      }
      // For older tasks, group by their actual creation date
      else {
        groupDate = taskCreatedDate;
      }

      if (groupedTasks[groupDate] == null) {
        groupedTasks[groupDate] = [];
      }
      groupedTasks[groupDate]!.add(task);
    }

    return groupedTasks;
  }

  /// Build task container with date header
  Widget _buildTaskContainer(DateTime date, List<Task> tasks) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppTheme.spacingS,
        right: AppTheme.spacingS,
        bottom: AppTheme.spacingL,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header with white background and black text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.containerBorderRadius),
                topRight: Radius.circular(AppTheme.containerBorderRadius),
              ),
            ),
            child: Text(
              _getDateLabel(date),
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Task tiles
          ...tasks.map((task) => _buildTaskTile(task)),
        ],
      ),
    );
  }

  /// Build individual task tile with improved boxy theme
  Widget _buildTaskTile(Task task) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          // Priority indicator
          if (task.priority != TaskPriority.none)
            Container(
              width: 4,
              height: 40,
              margin: const EdgeInsets.only(right: AppTheme.spacingM),
              decoration: BoxDecoration(
                color: task.priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Checkbox
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (value) => _onTaskToggle(task),
              activeColor: AppTheme.greyPrimary,
              checkColor: AppTheme.primaryText,
              side: BorderSide(
                color: AppTheme.greyLight,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spacingM),

          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTheme.bodyLarge.copyWith(
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted
                        ? AppTheme.secondaryText
                        : AppTheme.primaryText,
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    task.description!,
                    style: AppTheme.bodyMedium.copyWith(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted
                          ? AppTheme.disabledText
                          : AppTheme.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: AppTheme.spacingM),

          // Action buttons with boxy theme and proper spacing
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button - boxy design
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTaskEdit(task),
                  borderRadius:
                      BorderRadius.circular(AppTheme.buttonBorderRadius),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.greyLight.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppTheme.buttonBorderRadius),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  width: AppTheme.spacingS), // Proper spacing between buttons

              // Delete button - boxy design
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTaskDelete(task),
                  borderRadius:
                      BorderRadius.circular(AppTheme.buttonBorderRadius),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.buttonBorderRadius),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build task list for everyday tasks only (no routine tasks in containers)
  Widget _buildTaskList(bool isRoutineTab) {
    final taskStateStreamAsync = ref.watch(taskStateStreamProvider);

    return taskStateStreamAsync.when(
      data: (taskState) {
        if (isRoutineTab) {
          // For routine tasks, show the old layout
          final tasks = taskState.routineTasks;
          if (tasks.isEmpty) {
            return _buildEmptyState(isRoutineTab);
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
            child: PaginatedTaskList(
              tasks: tasks,
              itemsPerPage: 15, // Show 15 tasks per page
              taskBuilder: (task) => Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: _getTaskBackgroundColor(task),
                  borderRadius:
                      BorderRadius.circular(AppTheme.containerBorderRadius),
                ),
                child: _buildTaskTile(task),
              ),
              emptyState: _buildEmptyState(true),
            ),
          );
        } else {
          // For everyday tasks, show new container layout
          final everydayTasks = taskState.everydayTasks;

          if (everydayTasks.isEmpty) {
            return _buildEmptyState(isRoutineTab);
          }

          // Group tasks by date and use pagination for better performance
          final groupedTasks = _groupTasksByDate(everydayTasks);

          return PaginatedTaskContainerList(
            groupedTasks: groupedTasks,
            containerBuilder: _buildTaskContainer,
            containersPerPage: 5, // Show 5 date containers per page
            emptyState: _buildEmptyState(false),
          );
        }
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
        itemCount: 3,
        itemBuilder: (context, index) => ShimmerLoading(
          isLoading: true,
          child: const ShimmerTaskContainer(),
        ),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Failed to load tasks',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(taskStateStreamProvider);
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
    );
  }

  /// Build empty state
  Widget _buildEmptyState(bool isRoutineTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrey,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              isRoutineTab ? Icons.repeat : Icons.task_alt,
              size: 48,
              color: AppTheme.greyPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            isRoutineTab ? 'No routine tasks yet' : 'No tasks for today',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            isRoutineTab 
                ? 'Create routine tasks that repeat daily to build consistent habits'
                : 'Add tasks to organize your day and stay productive',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: _onAddTask,
            icon: const Icon(Icons.add, size: 20),
            label: Text(isRoutineTab ? 'Add Routine Task' : 'Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.greyPrimary,
              foregroundColor: AppTheme.primaryText,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get task background color based on priority
  Color _getTaskBackgroundColor(Task task) {
    if (task.priority == TaskPriority.none) {
      return AppTheme.surfaceGrey;
    }

    return Color.alphaBlend(
      task.priorityColor.withValues(alpha: 0.06),
      AppTheme.surfaceGrey,
    );
  }

  /// Handle add task
  Future<void> _onAddTask() async {
    final isRoutineTab = _tabController.index == 1;

    final result = await showModernAddTaskDialog(
      context,
      isRoutineTask: isRoutineTab,
      onTaskSaved: () {
        // No need to manually invalidate - TaskStateNotifier handles state updates automatically
      },
    );

    if (result == true && mounted) {
      ErrorHandler.showSuccessSnackBar(context, AppStrings.taskSavedSuccess);
    }
  }

  /// Get timezone-based greeting message
  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Build personalized greeting message
  Widget _buildGreeting() {
    final userNameAsync = ref.watch(userNameProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingS,
        AppTheme.spacingM,
        AppTheme.spacingS,
        AppTheme.spacingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timezone-based greeting
          Text(
            _getGreetingMessage(),
            style: AppTheme.headingLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),

          // Username on next line
          userNameAsync.when(
            data: (userName) {
              final displayName =
                  (userName?.isNotEmpty ?? false) ? userName! : 'there';
              return Text(
                '$displayName!',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              );
            },
            loading: () => Text(
              'there!',
              style: AppTheme.headingLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
            error: (_, __) => Text(
              'there!',
              style: AppTheme.headingLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseServiceAsync = ref.watch(asyncDatabaseServiceProvider);
    final preferencesServiceAsync = ref.watch(asyncPreferencesServiceProvider);

    return databaseServiceAsync.when(
      data: (dbService) => preferencesServiceAsync.when(
        data: (prefsService) => Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          appBar: const CustomAppBar(
            title: AppConstants.appName,
            showShareButton: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Personalized greeting
                _buildGreeting(),

                // Tab bar
                _buildTabBar(),

                const SizedBox(height: AppTheme.spacingM),

                // Tab view
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskList(
                          false), // Everyday tasks with new container design
                      _buildTaskList(true), // Routine tasks with old design
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.greyPrimary,
              borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onAddTask,
                borderRadius:
                    BorderRadius.circular(AppTheme.buttonBorderRadius),
                child: const Icon(
                  Icons.add,
                  color: AppTheme.primaryText,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        loading: () => const Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
            ),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Failed to initialize preferences service',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(asyncPreferencesServiceProvider);
                      ref.invalidate(asyncDatabaseServiceProvider);
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
      ),
      loading: () => const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Failed to initialize database service',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingL),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(asyncDatabaseServiceProvider);
                    ref.invalidate(asyncPreferencesServiceProvider);
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
    );
  }
}
