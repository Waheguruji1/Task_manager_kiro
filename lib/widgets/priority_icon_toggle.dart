import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/theme.dart';

/// Modern icon-based priority toggle widget
/// 
/// Provides intuitive priority selection using star and arrow icons
class PriorityIconToggle extends StatelessWidget {
  final TaskPriority selectedPriority;
  final Function(TaskPriority) onPriorityChanged;
  final bool enabled;

  const PriorityIconToggle({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPriorityIcon(
          icon: Icons.star,
          priority: TaskPriority.high,
          activeColor: const Color(0xFF8B5CF6), // Purple
          tooltip: 'High Priority',
        ),
        const SizedBox(width: AppTheme.spacingM),
        _buildPriorityIcon(
          icon: Icons.trending_up,
          priority: TaskPriority.medium,
          activeColor: const Color(0xFF10B981), // Green
          tooltip: 'Medium Priority',
        ),
      ],
    );
  }

  Widget _buildPriorityIcon({
    required IconData icon,
    required TaskPriority priority,
    required Color activeColor,
    required String tooltip,
  }) {
    final isSelected = selectedPriority == priority;
    final isActive = enabled && (isSelected || selectedPriority == TaskPriority.none);

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isActive ? () => _handlePriorityTap(priority) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected 
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected 
                ? Border.all(color: activeColor.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: isSelected ? 1.1 : 1.0,
            child: Icon(
              icon,
              size: 20,
              color: isSelected 
                  ? activeColor
                  : (isActive 
                      ? AppTheme.secondaryText.withValues(alpha: 0.6)
                      : AppTheme.secondaryText.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePriorityTap(TaskPriority priority) {
    if (selectedPriority == priority) {
      // Deselect if already selected
      onPriorityChanged(TaskPriority.none);
    } else {
      // Select new priority
      onPriorityChanged(priority);
    }
  }
}