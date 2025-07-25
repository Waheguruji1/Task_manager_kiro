import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/task_container.dart';
import '../widgets/add_task_dialog.dart';
import '../services/preferences_service.dart';
import '../services/database_service.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/responsive.dart';

/// Home Screen Widget
/// 
/// The main task management interface with tabbed organization for
/// everyday and routine tasks. Features personalized greeting,
/// custom AppBar with share functionality, and task loading/display logic.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late PreferencesService _preferencesService;
  late DatabaseService _databaseService;
  
  String _userName = '';
  List<Task> _routineTasks = [];
  List<Task> _combinedEverydayTasks = []; // Everyday + Routine tasks for display
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Initialize services and load initial data
  Future<void> _initializeServices() async {
    try {
      _preferencesService = await PreferencesService.getInstance();
      _databaseService = await DatabaseService.getInstance();
      await _databaseService.initialize();
      
      setState(() {
        _isInitialized = true;
      });
      
      await _loadUserData();
      await _checkAndResetDailyTasks();
      await _loadTasks();
    } catch (e) {
      ErrorHandler.logError(e, context: 'Home screen initialization', type: ErrorType.database);
      setState(() {
        _errorMessage = e is AppException ? e.message : AppStrings.errorDatabaseConnection;
        _isLoading = false;
        _isInitialized = true;
      });
    }
  }

  /// Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final userName = await _preferencesService.getUserName();
      setState(() {
        _userName = userName ?? '';
      });
    } catch (e) {
      ErrorHandler.logError(e, context: 'Load user data', type: ErrorType.preferences);
      setState(() {
        _userName = '';
      });
    }
  }

  /// Check if it's a new day and reset routine tasks if needed
  Future<void> _checkAndResetDailyTasks() async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      
      // Get the last reset date from SharedPreferences
      final lastResetDate = await _preferencesService.getLastResetDate();
      
      // If it's a new day, reset routine tasks
      if (lastResetDate != todayString) {
        ErrorHandler.logError('New day detected. Resetting routine tasks...', context: 'Daily reset', type: ErrorType.unknown);
        
        final success = await _databaseService.resetDailyRoutineTasks();
        if (success) {
          // Save today's date as the last reset date
          await _preferencesService.setLastResetDate(todayString);
          ErrorHandler.logError('Routine tasks reset successfully for $todayString', context: 'Daily reset', type: ErrorType.unknown);
        } else {
          ErrorHandler.logError('Failed to reset routine tasks', context: 'Daily reset', type: ErrorType.database);
        }
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'Check and reset daily tasks', type: ErrorType.database);
      // Don't throw error as this shouldn't prevent app from loading
    }
  }

  /// Load tasks from database
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load everyday tasks (non-routine)
      final everydayTasks = await _databaseService.getEverydayTasks();
      
      // Load routine tasks
      final routineTasks = await _databaseService.getRoutineTasks();
      
      // Combine everyday tasks with routine tasks for display in everyday tab
      final combinedTasks = [...everydayTasks, ...routineTasks];
      
      setState(() {
        _routineTasks = routineTasks;
        _combinedEverydayTasks = combinedTasks;
        _isLoading = false;
      });
    } catch (e) {
      ErrorHandler.logError(e, context: 'Load tasks', type: ErrorType.database);
      setState(() {
        _errorMessage = e is AppException ? e.message : AppStrings.errorLoadingTasks;
        _isLoading = false;
      });
    }
  }

  /// Handle task completion toggle
  Future<void> _onTaskToggle(Task task) async {
    if (task.id == null) return;
    
    try {
      final success = await _databaseService.toggleTaskCompletion(task.id!);
      if (success) {
        await _loadTasks(); // Reload tasks to reflect changes
        
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
        // Reload tasks after saving
        _loadTasks();
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
      final success = await _databaseService.deleteTask(task.id!);
      if (success) {
        await _loadTasks(); // Reload tasks to reflect changes
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, AppStrings.taskDeletedSuccess);
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, AppStrings.errorDeletingTask);
        }
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
        // Reload tasks after saving
        _loadTasks();
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
    
    final displayName = _userName.isNotEmpty ? _userName : 'there';
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
          Text(
            '$greeting, $displayName!',
            style: AppTheme.headingLarge.copyWith(
              fontSize: 28 * fontMultiplier,
              fontWeight: FontWeight.w600,
              height: 1.2,
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
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
          border: Border.all(color: AppTheme.borderColor),
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
            color: AppTheme.purplePrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius - 1),
            border: Border.all(
              color: AppTheme.purplePrimary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppTheme.purplePrimary,
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
            AppTheme.purplePrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }

  /// Build task content for tabs
  Widget _buildTaskContent() {
    if (_isLoading) {
      return const LoadingWidget(
        message: AppStrings.loadingTasks,
      );
    }

    if (_errorMessage != null) {
      return ErrorDisplayWidget(
        message: _errorMessage!,
        onRetry: _loadTasks,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Everyday Tasks Tab (includes routine tasks)
        _buildTaskList(_combinedEverydayTasks, AppStrings.noEverydayTasksMessage),
        
        // Routine Tasks Tab
        _buildTaskList(_routineTasks, AppStrings.noRoutineTasksMessage),
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
    // Show loading screen while initializing
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purplePrimary),
          ),
        ),
      );
    }

    return Scaffold(
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
          
          // Tab bar
          _buildTabBar(),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Task content
          Expanded(
            child: _buildTaskContent(),
          ),
        ],
      ),
    );
  }
}