import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../utils/error_handler.dart';
import '../utils/constants.dart';
import '../utils/validation.dart';
import '../utils/responsive.dart';
import '../utils/time_input_validator.dart';
import '../providers/providers.dart';
import 'custom_text_field.dart';
import 'time_input_field.dart';

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
  final _notificationTimeInputController = TextEditingController();
  DateTime? _notificationTime;
  TimeValidationResult? _timeValidationResult;
  bool _isLoading = false;
  String? _errorMessage;

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
        _notificationTime = widget.task!.notificationTime!;
        // Populate text field with formatted time for display
        _notificationTimeInputController.text = TimeInputValidator.formatTimeForDisplay(_notificationTime!);
        // Initialize validation result with proper state for existing time
        _timeValidationResult = TimeValidationResult.success(
          _notificationTime!.hour,
          _notificationTime!.minute,
        );
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
    _notificationTimeInputController.dispose();
    super.dispose();
  }

  /// Validate the task title
  String? _validateTitle(String? value) {
    return ValidationUtils.validateTaskTitle(value);
  }

  /// Validate the entire form including time input
  String? _validateForm() {
    // Check if time input is invalid (not empty but malformed)
    if (!_isRoutine && _timeValidationResult != null && !_timeValidationResult!.isValid && !_timeValidationResult!.isEmpty) {
      return _timeValidationResult!.errorMessage;
    }
    return null;
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

  /// Handle time input changes from TimeInputField
  void _onTimeInputChanged(TimeValidationResult validation) {
    setState(() {
      // Update validation result immediately for real-time feedback
      _timeValidationResult = validation;
      
      if (validation.isValid && !validation.isEmpty) {
        // Update notification time for valid input
        _notificationTime = validation.toDateTime();
      } else if (validation.isEmpty) {
        // Clear notification time when user clears the input field
        _notificationTime = null;
      }
      // For invalid input, maintain previous valid time (don't update _notificationTime)
      // This ensures we keep the last valid state while showing validation errors
    });
  }

  /// Save the task to the database
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate time input before proceeding
    final timeError = _validateForm();
    if (timeError != null) {
      setState(() {
        _errorMessage = timeError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskText = _titleController.text.trim();
      
      // Get task state notifier from Riverpod provider
      final taskStateNotifier = await ref.read(asyncTaskStateNotifierProvider.future);
      
      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: taskText,
          description: null, // No separate description field
          isRoutine: _isRoutine,
          priority: _isRoutine ? TaskPriority.none : _selectedPriority,
          notificationTime: _isRoutine ? null : _notificationTime,
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
          notificationTime: _isRoutine ? null : _notificationTime,
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
                maxLines: null,
                minLines: 2,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Routine Task Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
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
                    Switch.adaptive(
                      value: _isRoutine,
                      onChanged: (value) {
                        setState(() {
                          _isRoutine = value;
                          // Clear notification time when switching to routine task
                          if (_isRoutine) {
                            _notificationTime = null;
                            _notificationTimeInputController.clear();
                            _timeValidationResult = null;
                          }
                        });
                      },
                      activeThumbColor: AppTheme.greyPrimary,
                      inactiveThumbColor: AppTheme.secondaryText,
                      inactiveTrackColor: AppTheme.greyLight.withValues(alpha: 0.2),
                      activeTrackColor: AppTheme.greyPrimary.withValues(alpha: 0.3),
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
                    color: AppTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
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
                
                // Manual Time Input Field
                TimeInputField(
                  controller: _notificationTimeInputController,
                  labelText: 'Notification Time',
                  hintText: TimeInputValidator.timeFormatHint,
                  onTimeChanged: _onTimeInputChanged,
                  initialValidationResult: _timeValidationResult,
                ),
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