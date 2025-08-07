import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../utils/error_handler.dart';
import '../utils/constants.dart';
import '../utils/validation.dart';
import '../utils/responsive.dart';
import '../providers/providers.dart';
import 'custom_text_field.dart';

/// Add/Edit Task Dialog Widget
/// 
/// A dialog widget for creating new tasks or editing existing ones.
/// Provides form validation, error handling, and database integration.
class AddTaskDialog extends ConsumerStatefulWidget {
  /// The task to edit (null for creating a new task)
  final Task? task;
  
  /// Whether this task should be created as a routine task
  final bool isRoutineTask;
  
  /// Callback function called when a task is successfully saved
  final VoidCallback? onTaskSaved;

  const AddTaskDialog({
    super.key,
    this.task,
    this.isRoutineTask = false,
    this.onTaskSaved,
  });

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  late bool _isRoutine;
  TaskPriority _selectedPriority = TaskPriority.none;
  String? _selectedNotificationOption;
  DateTime? _customNotificationTime;
  bool _isLoading = false;
  String? _errorMessage;

  // Notification options
  static const Map<String, String> _notificationOptions = {
    '1hr': '1 hour before',
    '2hr': '2 hours before',
    'custom': 'Custom time',
  };

  @override
  void initState() {
    super.initState();
    _initializeDialog();
  }

  /// Initialize the dialog with existing task data or default values
  void _initializeDialog() {
    if (widget.task != null) {
      // Editing existing task
      _titleController.text = widget.task!.title;
      _isRoutine = widget.task!.isRoutine;
      _selectedPriority = widget.task!.priority;
      
      // Initialize notification settings if task has notification time
      if (widget.task!.notificationTime != null) {
        final notificationTime = widget.task!.notificationTime!;
        final now = DateTime.now();
        final difference = notificationTime.difference(now);
        
        if (difference.inHours == 1) {
          _selectedNotificationOption = '1hr';
        } else if (difference.inHours == 2) {
          _selectedNotificationOption = '2hr';
        } else {
          _selectedNotificationOption = 'custom';
          _customNotificationTime = notificationTime;
        }
      }
    } else {
      // Creating new task
      _isRoutine = widget.isRoutineTask;
      _selectedPriority = TaskPriority.none;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Validate the task title
  String? _validateTitle(String? value) {
    return ValidationUtils.validateTaskTitle(value);
  }

  /// Calculate notification time based on selected option
  DateTime? _calculateNotificationTime() {
    if (_selectedNotificationOption == null) return null;
    
    final now = DateTime.now();
    
    switch (_selectedNotificationOption) {
      case '1hr':
        return now.add(const Duration(hours: 1));
      case '2hr':
        return now.add(const Duration(hours: 2));
      case 'custom':
        return _customNotificationTime;
      default:
        return null;
    }
  }

  /// Show time picker for custom notification time
  Future<void> _showCustomTimePicker() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _customNotificationTime != null
          ? TimeOfDay.fromDateTime(_customNotificationTime!)
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.greyPrimary,
              onPrimary: AppTheme.primaryText,
              surface: AppTheme.surfaceGrey,
              onSurface: AppTheme.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // If the selected time is in the past, set it for tomorrow
      final finalDateTime = selectedDateTime.isBefore(now)
          ? selectedDateTime.add(const Duration(days: 1))
          : selectedDateTime;

      setState(() {
        _customNotificationTime = finalDateTime;
      });
    }
  }

  /// Get priority display text
  String _getPriorityDisplayText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High Priority';
      case TaskPriority.medium:
        return 'Medium Priority';
      case TaskPriority.none:
        return 'No Priority';
    }
  }

  /// Get priority color for dropdown items
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFF8B5CF6); // Purple
      case TaskPriority.medium:
        return const Color(0xFF10B981); // Green
      case TaskPriority.none:
        return AppTheme.secondaryText;
    }
  }

  /// Save the task to the database
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskText = _titleController.text.trim();
      final notificationTime = _calculateNotificationTime();
      
      // Get task state notifier from Riverpod provider
      final taskStateNotifier = await ref.read(asyncTaskStateNotifierProvider.future);
      
      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: taskText,
          description: null, // No separate description field
          isRoutine: _isRoutine,
          priority: _isRoutine ? TaskPriority.none : _selectedPriority,
          notificationTime: _isRoutine ? null : notificationTime,
          // Don't set notificationId here - TaskStateNotifier will handle it
        );
        
        final success = await taskStateNotifier.updateTask(updatedTask);
        
        if (success) {
          widget.onTaskSaved?.call();
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          setState(() {
            _errorMessage = AppStrings.errorUpdatingTask;
          });
        }
      } else {
        // Create new task
        final newTask = Task(
          title: taskText,
          description: null, // No separate description field
          isRoutine: _isRoutine,
          createdAt: DateTime.now(),
          priority: _isRoutine ? TaskPriority.none : _selectedPriority,
          notificationTime: _isRoutine ? null : notificationTime,
          // Don't set notificationId here - TaskStateNotifier will handle it
        );
        
        final success = await taskStateNotifier.addTask(newTask);
        
        if (success) {
          widget.onTaskSaved?.call();
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          setState(() {
            _errorMessage = AppStrings.errorSavingTask;
          });
        }
      }
    } catch (e) {
      String errorMessage = widget.task != null 
          ? AppStrings.errorUpdatingTask 
          : AppStrings.errorSavingTask;
      
      if (e is AppException) {
        errorMessage = e.message;
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Cancel and close the dialog
  void _cancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final dialogWidth = ResponsiveUtils.getDialogWidth(context);
    final responsiveSpacing = ResponsiveUtils.getSpacing(context, AppTheme.spacingL);
    
    return Dialog(
      backgroundColor: AppTheme.surfaceGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        side: const BorderSide(color: AppTheme.borderWhite),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: ResponsiveUtils.isSmallScreen(context) ? 
            MediaQuery.of(context).size.height * 0.9 : 600,
        ),
        padding: EdgeInsets.all(responsiveSpacing),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Dialog Title
              Text(
                isEditing ? 'Edit Task' : 'Add New Task',
                style: AppTheme.headingMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Single Task Input (Title + Description)
              CustomTextField(
                controller: _titleController,
                labelText: 'Task',
                hintText: 'Enter your task...',
                validator: _validateTitle,
                autofocus: true,
                maxLines: 3,
                minLines: 1,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Routine Task Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGrey,
                  borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                  border: Border.all(color: AppTheme.borderWhite, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Routine Task',
                            style: AppTheme.bodyLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Appears daily in everyday tasks',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isRoutine,
                      onChanged: (value) {
                        setState(() {
                          _isRoutine = value;
                        });
                      },
                      thumbColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppTheme.greyPrimary;
                          }
                          return AppTheme.secondaryText;
                        },
                      ),
                      trackColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppTheme.greyPrimary.withValues(alpha: 0.5);
                          }
                          return AppTheme.borderWhite;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Priority and Notification Options (hidden for routine tasks)
              if (!_isRoutine) ...[
                const SizedBox(height: AppTheme.spacingM),
                
                // Priority Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGrey,
                    borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                    border: Border.all(color: AppTheme.borderWhite, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority',
                              style: AppTheme.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Set task importance level',
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<TaskPriority>(
                        value: _selectedPriority,
                        onChanged: (TaskPriority? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedPriority = newValue;
                            });
                          }
                        },
                        dropdownColor: AppTheme.surfaceGrey,
                        style: AppTheme.bodyMedium,
                        underline: Container(),
                        icon: const Icon(
                          Icons.keyboard_arrow_up,
                          color: AppTheme.primaryText,
                        ),
                        isExpanded: false,
                        alignment: AlignmentDirectional.centerEnd,
                        menuMaxHeight: 200,
                        borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                        items: TaskPriority.values.map((TaskPriority priority) {
                          return DropdownMenuItem<TaskPriority>(
                            value: priority,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingS),
                                Text(
                                  _getPriorityDisplayText(priority),
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: _getPriorityColor(priority),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingM),
                
                // Notification Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGrey,
                    borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                    border: Border.all(color: AppTheme.borderWhite, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notification',
                              style: AppTheme.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedNotificationOption != null
                                  ? _notificationOptions[_selectedNotificationOption]!
                                  : 'No reminder set',
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedNotificationOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedNotificationOption = newValue;
                            if (newValue == 'custom') {
                              _showCustomTimePicker();
                            }
                          });
                        },
                        dropdownColor: AppTheme.surfaceGrey,
                        style: AppTheme.bodyMedium,
                        underline: Container(),
                        icon: const Icon(
                          Icons.keyboard_arrow_up,
                          color: AppTheme.primaryText,
                        ),
                        isExpanded: false,
                        alignment: AlignmentDirectional.centerEnd,
                        menuMaxHeight: 200,
                        borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                        hint: Text(
                          'None',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        items: [
                          // None option
                          DropdownMenuItem<String>(
                            value: null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.notifications_off,
                                  color: AppTheme.secondaryText,
                                  size: 16,
                                ),
                                const SizedBox(width: AppTheme.spacingS),
                                Text(
                                  'No reminder',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Notification options
                          ..._notificationOptions.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.notifications,
                                    color: AppTheme.primaryText,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Text(
                                    entry.value,
                                    style: AppTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Custom time display
                if (_selectedNotificationOption == 'custom' && _customNotificationTime != null) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.greyDark,
                      borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                      border: Border.all(color: AppTheme.borderWhite.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: AppTheme.secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Reminder at ${TimeOfDay.fromDateTime(_customNotificationTime!).format(context)}',
                          style: AppTheme.caption,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _showCustomTimePicker,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryText,
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
                          ),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              
              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: AppTheme.spacingM),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _cancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.borderWhite),
                        foregroundColor: AppTheme.secondaryText,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  
                  const SizedBox(width: AppTheme.spacingM),
                  
                  // Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.greyPrimary,
                        foregroundColor: AppTheme.primaryText,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryText,
                                ),
                              ),
                            )
                          : Text(isEditing ? 'Update' : 'Add Task'),
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the add task dialog
Future<bool?> showAddTaskDialog(
  BuildContext context, {
  bool isRoutineTask = false,
  VoidCallback? onTaskSaved,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AddTaskDialog(
      isRoutineTask: isRoutineTask,
      onTaskSaved: onTaskSaved,
    ),
  );
}

/// Helper function to show the edit task dialog
Future<bool?> showEditTaskDialog(
  BuildContext context, {
  required Task task,
  VoidCallback? onTaskSaved,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AddTaskDialog(
      task: task,
      onTaskSaved: onTaskSaved,
    ),
  );
}