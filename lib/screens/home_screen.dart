import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/add_task_dialog.dart';
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
      
      // Check if this is a routine task template
      if (task.isRoutine && task.routineTaskId == null) {
        // This is a routine task template - delete the routine task and all its instances
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
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.greyPrimary,
          borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius - 2),
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
        tabs: const [
          Tab(text: 'Everyday Tasks'),
          Tab(text: 'Routine Tasks'),
        ],
      ),
    );
  }

  /// Build task list for a specific tab
  Widget _buildTaskList(bool isRoutineTab) {
    final tasksAsync = isRoutineTab
        ? ref.watch(routineTasksProvider)
        : ref.watch(everydayTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyState(isRoutineTab);
        }

        // Sort tasks by priority
        final sortedTasks = Task.sortByPriority(tasks);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              final task = sortedTasks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: _getTaskBackgroundColor(task),
                  borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingM,
                  ),
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
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted 
                                  ? AppTheme.secondaryText 
                                  : AppTheme.primaryText,
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              height: 1.4,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                          
                          if (task.description != null && task.description!.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacingXS),
                            Text(
                              task.description!,
                              style: AppTheme.bodyMedium.copyWith(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                color: task.isCompleted 
                                    ? AppTheme.disabledText 
                                    : AppTheme.secondaryText,
                                fontSize: 15,
                                height: 1.4,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                          
                          if (task.isRoutine) ...[
                            const SizedBox(height: AppTheme.spacingS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingS,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.greyPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    size: 12,
                                    color: AppTheme.greyPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Routine',
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.greyPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: AppTheme.spacingS),
                    
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onTaskEdit(task),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.greyLight.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: AppTheme.spacingXS),
                        
                        // Delete button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onTaskDelete(task),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
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
              ),
            );
          },
        ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greyPrimary),
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
                if (isRoutineTab) {
                  ref.invalidate(routineTasksProvider);
                } else {
                  ref.invalidate(everydayTasksProvider);
                }
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
    
    final result = await showAddTaskDialog(
      context,
      isRoutineTask: isRoutineTab,
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
          // Greeting message
          Text(
            'Hello 👋',
            style: AppTheme.headingLarge.copyWith(
              fontSize: 28 * fontMultiplier,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: AppTheme.primaryText,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXS),
          
          // Username with proper spacing
          userNameAsync.when(
            data: (userName) {
              final displayName = (userName?.isNotEmpty ?? false) ? userName! : 'there';
              return Text(
                '$displayName !',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: 28 * fontMultiplier,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: AppTheme.primaryText,
                ),
              );
            },
            loading: () => Text(
              'there !',
              style: AppTheme.headingLarge.copyWith(
                fontSize: 28 * fontMultiplier,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppTheme.primaryText,
              ),
            ),
            error: (_, __) => Text(
              'there !',
              style: AppTheme.headingLarge.copyWith(
                fontSize: 28 * fontMultiplier,
                fontWeight: FontWeight.w600,
                height: 1.2,
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
                    _buildTaskList(false), // Everyday tasks
                    _buildTaskList(true),  // Routine tasks
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.greyPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _onAddTask,
                borderRadius: BorderRadius.circular(16),
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