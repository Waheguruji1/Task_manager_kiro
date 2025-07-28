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
  final _descriptionController = TextEditingController();
  
  late bool _isRoutine;
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
      _descriptionController.text = widget.task!.description ?? '';
      _isRoutine = widget.task!.isRoutine;
    } else {
      // Creating new task
      _isRoutine = widget.isRoutineTask;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validate the task title
  String? _validateTitle(String? value) {
    return ValidationUtils.validateTaskTitle(value);
  }

  /// Validate the task description
  String? _validateDescription(String? value) {
    return ValidationUtils.validateTaskDescription(value);
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
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      // Get database service from Riverpod provider
      final databaseService = await ref.read(asyncDatabaseServiceProvider.future);
      
      if (widget.task != null) {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: title,
          description: description.isEmpty ? null : description,
          isRoutine: _isRoutine,
        );
        
        final success = await databaseService.updateTask(updatedTask);
        
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
          title: title,
          description: description.isEmpty ? null : description,
          isRoutine: _isRoutine,
          createdAt: DateTime.now(),
        );
        
        final taskId = await databaseService.createTask(newTask);
        
        if (taskId > 0) {
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
              
              // Task Title Input
              CustomTextField(
                controller: _titleController,
                labelText: 'Task Title',
                hintText: 'Enter task title',
                validator: _validateTitle,
                autofocus: true,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Task Description Input
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description (Optional)',
                hintText: 'Enter task description',
                maxLines: 3,
                minLines: 1,
                validator: _validateDescription,
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