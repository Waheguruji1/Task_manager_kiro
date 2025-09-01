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
import 'priority_icon_toggle.dart';
import 'notification_icon_toggle.dart';

/// Modern, minimalistic task input dialog
/// 
/// Features:
/// - Larger input container
/// - Icon-based priority selection
/// - Context-aware functionality (routine vs everyday)
/// - Notification modal integration
class ModernAddTaskDialog extends ConsumerStatefulWidget {
  /// The task to edit (null for creating a new task)
  final Task? task;
  
  /// Whether this task should be created as a routine task
  final bool isRoutineTask;
  
  /// Callback function called when a task is successfully saved
  final VoidCallback? onTaskSaved;

  const ModernAddTaskDialog({
    super.key,
    this.task,
    this.isRoutineTask = false,
    this.onTaskSaved,
  });

  @override
  ConsumerState<ModernAddTaskDialog> createState() => _ModernAddTaskDialogState();
}

class _ModernAddTaskDialogState extends ConsumerState<ModernAddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  late bool _isRoutine;
  TaskPriority _selectedPriority = TaskPriority.none;
  DateTime? _notificationTime;
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
      _notificationTime = widget.task!.notificationTime;
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

  /// Handle priority selection
  void _onPriorityChanged(TaskPriority priority) {
    setState(() {
      _selectedPriority = priority;
    });
  }

  /// Handle notification time changes
  void _onNotificationChanged(DateTime? time) {
    setState(() {
      _notificationTime = time;
    });
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
            MediaQuery.of(context).size.height * 0.8 : 500,
        ),
        padding: EdgeInsets.all(responsiveSpacing),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Title
              Text(
                isEditing ? 'Edit Task' : (_isRoutine ? 'Add Routine Task' : 'Add New Task'),
                style: AppTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Main Input Container - Larger and more prominent
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
                  border: Border.all(
                    color: AppTheme.borderWhite.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Label
                    Text(
                      'What needs to be done?',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingM),
                    
                    // Large Task Input Field
                    CustomTextField(
                      controller: _titleController,
                      labelText: null, // No label since we have the question above
                      hintText: 'Enter your task...',
                      validator: _validateTitle,
                      autofocus: true,
                      maxLines: null,
                      minLines: 3, // Larger input area
                      style: AppTheme.bodyLarge.copyWith(
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    
                    // Action Icons (only for non-routine tasks)
                    if (!_isRoutine) ...[
                      const SizedBox(height: AppTheme.spacingL),
                      
                      Row(
                        children: [
                          // Priority Icons
                          PriorityIconToggle(
                            selectedPriority: _selectedPriority,
                            onPriorityChanged: _onPriorityChanged,
                            enabled: true,
                          ),
                          
                          const SizedBox(width: AppTheme.spacingL),
                          
                          // Notification Icon
                          NotificationIconToggle(
                            notificationTime: _notificationTime,
                            onNotificationChanged: _onNotificationChanged,
                            enabled: true,
                          ),
                          
                          const Spacer(),
                          
                          // Priority/Notification Status Text
                          if (_selectedPriority != TaskPriority.none || _notificationTime != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                                vertical: AppTheme.spacingS,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.greyPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                              ),
                              child: Text(
                                _getStatusText(),
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.greyPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: AppTheme.spacingM),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
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
                        size: 18,
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
              
              const SizedBox(height: AppTheme.spacingXL),
              
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
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
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
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryText,
                                ),
                              ),
                            )
                          : Text(isEditing ? 'Update Task' : 'Add Task'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get status text for selected priority and notification
  String _getStatusText() {
    final List<String> status = [];
    
    if (_selectedPriority == TaskPriority.high) {
      status.add('High Priority');
    } else if (_selectedPriority == TaskPriority.medium) {
      status.add('Medium Priority');
    }
    
    if (_notificationTime != null) {
      final hour = _notificationTime!.hour.toString().padLeft(2, '0');
      final minute = _notificationTime!.minute.toString().padLeft(2, '0');
      status.add('Notify at $hour:$minute');
    }
    
    return status.join(' • ');
  }
}

/// Helper function to show the modern add task dialog
Future<bool?> showModernAddTaskDialog(
  BuildContext context, {
  bool isRoutineTask = false,
  VoidCallback? onTaskSaved,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ModernAddTaskDialog(
      isRoutineTask: isRoutineTask,
      onTaskSaved: onTaskSaved,
    ),
  );
}

/// Helper function to show the modern edit task dialog
Future<bool?> showModernEditTaskDialog(
  BuildContext context, {
  required Task task,
  VoidCallback? onTaskSaved,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ModernAddTaskDialog(
      task: task,
      onTaskSaved: onTaskSaved,
    ),
  );
}