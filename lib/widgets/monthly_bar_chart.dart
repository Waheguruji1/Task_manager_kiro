import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

/// Monthly Bar Chart Widget
/// 
/// Displays task completion data as vertical bars for each month
/// Shows only current year data with clean, minimal design
class MonthlyBarChart extends StatefulWidget {
  final List<Task> tasks;
  final int selectedMonth;
  final Function(int) onMonthChanged;

  const MonthlyBarChart({
    super.key,
    required this.tasks,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  final int currentYear = DateTime.now().year;

  /// Calculate monthly completion data for current year
  Map<int, int> _calculateMonthlyData() {
    final Map<int, int> monthlyData = {};
    
    // Initialize all months with 0
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = 0;
    }

    // Count completed tasks by month for current year only
    for (final task in widget.tasks) {
      if (task.isCompleted && task.completedAt != null) {
        final completedDate = task.completedAt!;
        if (completedDate.year == currentYear) {
          final month = completedDate.month;
          monthlyData[month] = (monthlyData[month] ?? 0) + 1;
        }
      }
    }

    return monthlyData;
  }

  /// Get the maximum value for scaling bars
  int _getMaxValue(Map<int, int> data) {
    final maxValue = data.values.isEmpty ? 0 : data.values.reduce((a, b) => a > b ? a : b);
    return maxValue == 0 ? 1 : maxValue; // Avoid division by zero
  }

  /// Get bar color based on completion count
  Color _getBarColor(int count, int maxValue) {
    if (count == 0) return AppTheme.greyLight.withValues(alpha: 0.3);
    
    final intensity = count / maxValue;
    if (intensity >= 0.8) return Colors.green;
    if (intensity >= 0.6) return Colors.lightGreen;
    if (intensity >= 0.4) return Colors.orange;
    if (intensity >= 0.2) return Colors.amber;
    return AppTheme.greyPrimary.withValues(alpha: 0.7);
  }

  /// Build individual bar for a month with responsive design
  Widget _buildBar(BuildContext context, int month, int count, int maxValue) {
    final isSelected = month == widget.selectedMonth;
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final barHeight = maxValue > 0 ? (count / maxValue * (isSmallScreen ? 100 : 120)).clamp(4.0, isSmallScreen ? 100.0 : 120.0) : 4.0;
    final barColor = _getBarColor(count, maxValue);
    final barWidth = isSmallScreen ? 20.0 : 24.0;
    
    return GestureDetector(
      onTap: () => widget.onMonthChanged(month),
      child: SizedBox(
        width: barWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Count label
            SizedBox(
              height: 20,
              child: count > 0 
                ? Text(
                    count.toString(),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  )
                : null,
            ),
            
            const SizedBox(height: 4),
            
            // Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isSelected ? barWidth : barWidth - 4,
              height: barHeight,
              decoration: BoxDecoration(
                color: isSelected 
                  ? barColor 
                  : barColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(isSelected ? 6 : 4),
                border: isSelected 
                  ? Border.all(color: AppTheme.primaryText.withValues(alpha: 0.3), width: 1)
                  : null,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: barColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Month label
            Text(
              DateFormat('MMM').format(DateTime(currentYear, month)),
              style: AppTheme.caption.copyWith(
                color: isSelected 
                  ? AppTheme.primaryText 
                  : AppTheme.secondaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthlyData = _calculateMonthlyData();
    final maxValue = _getMaxValue(monthlyData);
    final totalCompleted = monthlyData.values.fold(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius + 2),
        border: Border.all(
          color: AppTheme.greyPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.greyPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: AppTheme.greyPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Completion',
                      style: AppTheme.headingMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Text(
                      '$totalCompleted tasks completed in $currentYear',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Chart container with responsive height
          Container(
            height: ResponsiveUtils.isSmallScreen(context) ? 160 : 180,
            padding: EdgeInsets.all(ResponsiveUtils.isSmallScreen(context) ? AppTheme.spacingS : AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
              border: Border.all(
                color: AppTheme.greyPrimary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Chart area
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(12, (index) {
                      final month = index + 1;
                      final count = monthlyData[month] ?? 0;
                      return _buildBar(context, month, count, maxValue);
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Selected month info with responsive design
          if (widget.selectedMonth > 0) ...[
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.isSmallScreen(context) ? AppTheme.spacingS : AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.greyPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.greyPrimary,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 16),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      '${DateFormat('MMMM').format(DateTime(currentYear, widget.selectedMonth))}: ${monthlyData[widget.selectedMonth] ?? 0} tasks completed',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryText,
                        fontWeight: FontWeight.w500,
                        fontSize: ResponsiveUtils.isSmallScreen(context) ? 13 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}