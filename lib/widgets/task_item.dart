import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/theme.dart';
import '../utils/error_handler.dart';
import '../utils/responsive.dart';
import 'truncated_text.dart';

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
        color: _getTaskBackgroundColor(),
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: Border.all(
          color: _getTaskBorderColor(),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority indicator (subtle left border)
          if (task.priority != TaskPriority.none) _buildPriorityIndicator(),
          
          // Checkbox for completion toggle
          _buildCheckbox(),
          
          const SizedBox(width: AppTheme.spacingM),
          
          // Task content (title and description)
          Expanded(
            child: _buildTaskContent(context),
          ),
          
          const SizedBox(width: AppTheme.spacingS),
          
          // Action buttons (edit and delete)
          _buildActionButtons(context),
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
            color: AppTheme.greyPrimary.withValues(alpha: 0.2),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ] : null,
      ),
      child: Checkbox(
        value: task.isCompleted,
        onChanged: (value) => _safeCallback(() => onToggle(value), 'toggle task completion'),
        activeColor: AppTheme.greyPrimary,
        checkColor: AppTheme.primaryText,
        side: BorderSide(
          color: AppTheme.borderWhite,
          width: 2,
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
  Widget _buildTaskContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task title with completion styling and responsive truncation
        TruncatedText(
          text: task.title,
          maxLength: ResponsiveUtils.getTextTruncationLength(context, baseLength: 45),
          maxLines: 2,
          style: AppTheme.bodyLarge.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted 
                ? AppTheme.secondaryText 
                : AppTheme.primaryText,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          indicatorColor: task.isCompleted 
              ? AppTheme.disabledText 
              : AppTheme.secondaryText,
        ),
        
        // Task description (if available) with responsive truncation
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingXS),
          TruncatedText(
            text: task.description!,
            maxLength: ResponsiveUtils.getTextTruncationLength(context, baseLength: 70),
            maxLines: 3,
            style: AppTheme.bodyMedium.copyWith(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted 
                  ? AppTheme.disabledText 
                  : AppTheme.secondaryText,
              height: 1.4,
            ),
            indicatorColor: task.isCompleted 
                ? AppTheme.disabledText.withValues(alpha: 0.7)
                : AppTheme.secondaryText.withValues(alpha: 0.7),
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
                decoration: AppTheme.routineTaskLabelDecoration,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 12,
                      color: AppTheme.primaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Routine',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.primaryText,
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
  Widget _buildActionButtons(BuildContext context) {
    final iconSize = ResponsiveUtils.getIconSize(context, baseSize: 16);
    final buttonPadding = ResponsiveUtils.getButtonPadding(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _safeCallback(onEdit, 'edit task'),
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.greyPrimary.withValues(alpha: 0.1),
            highlightColor: AppTheme.greyPrimary.withValues(alpha: 0.05),
            child: Container(
              padding: EdgeInsets.all(buttonPadding.vertical),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.borderWhite.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                color: AppTheme.greyPrimary.withValues(alpha: 0.05),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: iconSize,
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
              padding: EdgeInsets.all(buttonPadding.vertical),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 0.5,
                ),
                color: Colors.red.withValues(alpha: 0.05),
              ),
              child: Icon(
                Icons.delete_outline,
                size: iconSize,
                color: Colors.red.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the priority indicator (subtle left border)
  Widget _buildPriorityIndicator() {
    return Container(
      width: 4,
      height: 32,
      margin: const EdgeInsets.only(right: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: task.priorityColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: task.priorityColor.withValues(alpha: 0.2),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  /// Gets the background color based on task priority
  Color _getTaskBackgroundColor() {
    if (task.priority == TaskPriority.none) {
      return AppTheme.surfaceGrey;
    }
    
    // Add more subtle tint for priority tasks - enhanced for better visual hierarchy
    return Color.alphaBlend(
      task.priorityColor.withValues(alpha: 0.06),
      AppTheme.surfaceGrey,
    );
  }

  /// Gets the border color based on task priority
  Color _getTaskBorderColor() {
    if (task.priority == TaskPriority.none) {
      return AppTheme.borderWhite;
    }
    
    // Enhanced subtle border color blend for better visual distinction
    return Color.alphaBlend(
      task.priorityColor.withValues(alpha: 0.12),
      AppTheme.borderWhite,
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