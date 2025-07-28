import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/task_container.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/compact_task_widget.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/responsive.dart';
import '../providers/providers.dart';

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

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeDailyTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Initialize daily routine tasks if needed
  Future<void> _initializeDailyTasks() async {
    try {
      final prefsService = await ref.read(asyncPreferencesServiceProvider.future);
      final dbService = await ref.read(asyncDatabaseServiceProvider.future);
      
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      // Get the last reset date from SharedPreferences
      final lastResetDate = await prefsService.getLastResetDate();
      
      // If it's a new day, create daily routine task instances
      if (lastResetDate != todayString) {
        ErrorHandler.logError('New day detected. Creating daily routine task instances...', context: 'Daily reset', type: ErrorType.unknown);
        
        final success = await dbService.createDailyRoutineTaskInstances();
        if (success) {
          // Save today's date as the last reset date
          await prefsService.setLastResetDate(todayString);
          ErrorHandler.logError('Daily routine task instances created successfully for $todayString', context: 'Daily reset', type: ErrorType.unknown);
        } else {
          ErrorHandler.logError('Failed to create daily routine task instances', context: 'Daily reset', type: ErrorType.database);
        }
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check and reset daily tasks', type: ErrorType.database);
      // Don't throw error as this shouldn't prevent app from loading
    }
  }

  /// Handle task completion toggle
  Future<void> _onTaskToggle(Task task) async {
    if (task.id == null) return;
    
    try {
      final taskStateNotifier = await ref.read(asyncTaskStateNotifierProvider.future);
      final success = await taskStateNotifier.toggleTaskCompletion(task.id!);
      
      if (success) {
        // Show success message for completed tasks
        if (!task.isCompleted && mounted) {
          ErrorHandler.showSuccessSnackBar(context, AppStrings.taskCompletedSuccess);
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, AppStrings.errorUpdatingTask);
        }
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'Toggle task completion', type: ErrorType.database);
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
    final result = await showEditTaskDialog(
      context,
      task: task,
      onTaskSaved: () {
        // Reload tasks after saving using Riverpod
        ref.invalidate(everydayTasksProvider);
        ref.invalidate(routineTasksProvider);
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
    
    try {
      final taskStateNotifier = await ref.read(asyncTaskStateNotifierProvider.future);
      bool success;
      
      // Check if we're in the routine tasks tab and this is a routine task template
      if (_tabController.index == 1 && task.isRoutine && task.routineTaskId == null) {
        // This is a routine task template being deleted from routine tab
        // Delete the routine task and all its instances
        success = await taskStateNotifier.deleteRoutineTaskAndInstances(task.id!);
      } else {
        // This is either a regular everyday task or a routine task instance
        // Just delete this specific task
        success = await taskStateNotifier.deleteTask(task.id!);
      }
      
      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(context, AppStrings.taskDeletedSuccess);
      } else if (mounted) {
        ErrorHandler.showErrorSnackBar(context, AppStrings.errorDeletingTask);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'Delete task', type: ErrorType.database);
      if (mounted) {
        String errorMessage = AppStrings.errorDeletingTask;
        if (e is AppException) {
          errorMessage = e.message;
        }
        ErrorHandler.showErrorSnackBar(context, errorMessage);
      }
    }
  }

  /// Handle add task
  Future<void> _onAddTask() async {
    // Determine if we're adding a routine task based on current tab
    final isRoutineTask = _tabController.index == 1;
    
    final result = await showAddTaskDialog(
      context,
      isRoutineTask: isRoutineTask,
      onTaskSaved: () {
        // Reload tasks after saving using Riverpod
        ref.invalidate(everydayTasksProvider);
        ref.invalidate(routineTasksProvider);
      },
    );
    
    if (result == true) {
      ErrorHandler.showSuccessSnackBar(context, AppStrings.taskSavedSuccess);
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



  /// Build compact task widgets
  Widget _buildCompactTaskWidgets() {
    return Column(
      children: [
        // Everyday Tasks Compact Widget
        CompactTaskWidget(
          title: 'Today\'s Tasks',
          showRoutineTasks: false,
          maxTasksWhenCollapsed: 4,
          onTaskToggle: _onTaskToggle,
          onTaskEdit: _onTaskEdit,
          onTaskDelete: _onTaskDelete,
          onAddTask: () => _onAddTaskForWidget(false),
        ),
        
        const SizedBox(height: AppTheme.spacingM),
        
        // Routine Tasks Compact Widget
        CompactTaskWidget(
          title: 'Routine Tasks',
          showRoutineTasks: true,
          maxTasksWhenCollapsed: 3,
          onTaskToggle: _onTaskToggle,
          onTaskEdit: _onTaskEdit,
          onTaskDelete: _onTaskDelete,
          onAddTask: () => _onAddTaskForWidget(true),
        ),
      ],
    );
  }

  /// Handle add task for compact widgets
  Future<void> _onAddTaskForWidget(bool isRoutineTask) async {
    final result = await showAddTaskDialog(
      context,
      isRoutineTask: isRoutineTask,
      onTaskSaved: () {
        // Reload tasks after saving using Riverpod
        ref.invalidate(everydayTasksProvider);
        ref.invalidate(routineTasksProvider);
      },
    );
    
    if (result == true && mounted) {
      ErrorHandler.showSuccessSnackBar(context, AppStrings.taskSavedSuccess);
    }
  }

  /// Build personalized greeting message
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = AppStrings.greetingMorning;
    } else if (hour < 17) {
      greeting = AppStrings.greetingAfternoon;
    } else {
      greeting = AppStrings.greetingEvening;
    }
    
    // Watch user name from Riverpod provider
    final userNameAsync = ref.watch(userNameProvider);
    final responsivePadding = ResponsiveUtils.getScreenPadding(context);
    final fontMultiplier = ResponsiveUtils.getFontSizeMultiplier(context);
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        responsivePadding.horizontal / 2,
        AppTheme.spacingL,
        responsivePadding.horizontal / 2,
        AppTheme.spacingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userNameAsync.when(
            data: (userName) {
              final displayName = (userName?.isNotEmpty ?? false) ? userName! : 'there';
              return Text(
                '$greeting, $displayName!',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: 28 * fontMultiplier,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              );
            },
            loading: () => Text(
              '$greeting, there!',
              style: AppTheme.headingLarge.copyWith(
                fontSize: 28 * fontMultiplier,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            error: (_, __) => Text(
              '$greeting, there!',
              style: AppTheme.headingLarge.copyWith(
                fontSize: 28 * fontMultiplier,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            AppStrings.dailyMotivation,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryText,
              height: 1.4,
              fontSize: 16 * fontMultiplier,
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab structure with labels
  Widget _buildTabBar() {
    final responsivePadding = ResponsiveUtils.getScreenPadding(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    final fontMultiplier = ResponsiveUtils.getFontSizeMultiplier(context);
    
    return Center(
      child: Container(
        width: contentWidth,
        margin: EdgeInsets.fromLTRB(
          responsivePadding.horizontal / 2,
          AppTheme.spacingS,
          responsivePadding.horizontal / 2,
          AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
          border: Border.all(color: AppTheme.borderWhite),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: AppStrings.everydayTasksTab,
              height: ResponsiveUtils.isSmallScreen(context) ? 44 : 48,
            ),
            Tab(
              text: AppStrings.routineTasksTab,
              height: ResponsiveUtils.isSmallScreen(context) ? 44 : 48,
            ),
          ],
          indicator: BoxDecoration(
            color: AppTheme.greyPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius - 1),
            border: Border.all(
              color: AppTheme.borderWhite,
              width: 1,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppTheme.primaryText,
          unselectedLabelColor: AppTheme.secondaryText,
          labelStyle: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16 * fontMultiplier,
          ),
          unselectedLabelStyle: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 16 * fontMultiplier,
          ),
          overlayColor: WidgetStateProperty.all(
            AppTheme.greyPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }

  /// Build task content for tabs
  Widget _buildTaskContent() {
    // Watch everyday and routine tasks from Riverpod providers
    final everydayTasksAsync = ref.watch(everydayTasksProvider);
    final routineTasksAsync = ref.watch(routineTasksProvider);

    return TabBarView(
      controller: _tabController,
      children: [
        // Everyday Tasks Tab (includes routine tasks)
        everydayTasksAsync.when(
          data: (tasks) => _buildTaskList(tasks, AppStrings.noEverydayTasksMessage),
          loading: () => const LoadingWidget(message: AppStrings.loadingTasks),
          error: (error, _) => ErrorDisplayWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(everydayTasksProvider),
          ),
        ),
        
        // Routine Tasks Tab
        routineTasksAsync.when(
          data: (tasks) => _buildTaskList(tasks, AppStrings.noRoutineTasksMessage),
          loading: () => const LoadingWidget(message: AppStrings.loadingTasks),
          error: (error, _) => ErrorDisplayWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(routineTasksProvider),
          ),
        ),
      ],
    );
  }

  /// Build task list for a tab
  Widget _buildTaskList(List<Task> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return EmptyStateWidget(
        title: AppStrings.emptyStateTitle,
        subtitle: emptyMessage,
        actionText: AppStrings.emptyStateAction,
        onAction: _onAddTask,
      );
    }

    return ListView.builder(
      itemCount: 3, // Top spacing, TaskContainer, Bottom spacing
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return const SizedBox(height: AppTheme.spacingM);
          case 1:
            return TaskContainer(
              key: ValueKey('task_container_${tasks.length}'), // Key for performance
              date: DateTime.now(),
              tasks: tasks,
              onAddTask: _onAddTask,
              onTaskToggle: _onTaskToggle,
              onTaskEdit: _onTaskEdit,
              onTaskDelete: _onTaskDelete,
            );
          case 2:
            return const SizedBox(height: AppTheme.spacingXL);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch async providers to ensure services are initialized
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personalized greeting
              _buildGreeting(),
              
              // Compact task widgets
              _buildCompactTaskWidgets(),
              
              // Tab bar
              _buildTabBar(),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Task content
              Expanded(
                child: _buildTaskContent(),
              ),
            ],
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
          body: Center(
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
        body: Center(
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
    );
  }
}