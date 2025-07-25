import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../utils/error_handler.dart';

/// Individual task item widget with checkbox, title, description, and action buttons
/// 
/// This widget represents a single task in the task list with interactive elements
/// for completion toggle, editing, and deletion. It provides visual distinction
/// between routine and everyday tasks.
class TaskItem extends StatelessWidget {
  /// The task data to display
  final Task task;
  
  /// Callback when task completion status is toggled
  final Function(bool?) onToggle;
  
  /// Callback when edit action is triggered
  final VoidCallback onEdit;
  
  /// Callback when delete action is triggered
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: task.isRoutine 
            ? AppTheme.purplePrimary.withValues(alpha: 0.05)
            : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: Border.all(
          color: task.isRoutine 
              ? AppTheme.purplePrimary.withValues(alpha: 0.4) 
              : AppTheme.borderColor,
          width: task.isRoutine ? 1.5 : 1,
        ),
        boxShadow: task.isRoutine ? [
          BoxShadow(
            color: AppTheme.purplePrimary.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ] : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox for completion toggle
          _buildCheckbox(),
          
          const SizedBox(width: AppTheme.spacingM),
          
          // Task content (title and description)
          Expanded(
            child: _buildTaskContent(),
          ),
          
          const SizedBox(width: AppTheme.spacingS),
          
          // Action buttons (edit and delete)
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Builds the checkbox for task completion toggle
  Widget _buildCheckbox() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: task.isCompleted ? [
          BoxShadow(
            color: AppTheme.purplePrimary.withValues(alpha: 0.2),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ] : null,
      ),
      child: Checkbox(
        value: task.isCompleted,
        onChanged: (value) => _safeCallback(() => onToggle(value), 'toggle task completion'),
        activeColor: AppTheme.purplePrimary,
        checkColor: AppTheme.primaryText,
        side: BorderSide(
          color: task.isCompleted 
              ? AppTheme.purplePrimary 
              : task.isRoutine 
                  ? AppTheme.purplePrimary.withValues(alpha: 0.4)
                  : AppTheme.borderColor,
          width: task.isCompleted ? 2 : 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Builds the task content section with title and description
  Widget _buildTaskContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task title with completion styling
        Text(
          task.title,
          style: AppTheme.bodyLarge.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted 
                ? AppTheme.secondaryText 
                : AppTheme.primaryText,
          ),
        ),
        
        // Task description (if available)
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            task.description!,
            style: AppTheme.bodyMedium.copyWith(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted 
                  ? AppTheme.disabledText 
                  : AppTheme.secondaryText,
            ),
          ),
        ],
        
        // Routine task indicator
        if (task.isRoutine) ...[
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.purplePrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.purplePrimary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 12,
                      color: AppTheme.purplePrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Routine',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.purplePrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Builds the action buttons for edit and delete
  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _safeCallback(onEdit, 'edit task'),
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.purplePrimary.withValues(alpha: 0.1),
            highlightColor: AppTheme.purplePrimary.withValues(alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppTheme.iconPrimary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingXS),
        
        // Delete button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _safeCallback(onDelete, 'delete task'),
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.red.withValues(alpha: 0.1),
            highlightColor: Colors.red.withValues(alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.red.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Safely execute callback functions with error handling
  void _safeCallback(VoidCallback callback, String operation) {
    try {
      callback();
    } catch (e) {
      ErrorHandler.logError(
        e,
        context: 'TaskItem $operation',
        type: ErrorType.unknown,
      );
      // Don't rethrow as this would break the UI
      // The parent widget should handle the actual error display
    }
  }
}