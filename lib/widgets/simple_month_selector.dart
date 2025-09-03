import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Simple month selector for current year only
class SimpleMonthSelector extends StatelessWidget {
  final int selectedMonth;
  final Function(int) onMonthChanged;
  final int currentYear;

  const SimpleMonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.currentYear,
  });

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(AppTheme.containerBorderRadius),
        border: Border.all(
          color: AppTheme.greyPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: AppTheme.greyPrimary,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Select Month - $currentYear',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Month grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.5,
              crossAxisSpacing: AppTheme.spacingS,
              mainAxisSpacing: AppTheme.spacingS,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == selectedMonth;
              final isCurrentMonth = month == DateTime.now().month;
              
              return GestureDetector(
                onTap: () => onMonthChanged(month),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.greyPrimary
                        : isCurrentMonth
                            ? AppTheme.greyPrimary.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.greyPrimary
                          : isCurrentMonth
                              ? AppTheme.greyPrimary.withValues(alpha: 0.3)
                              : AppTheme.greyPrimary.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _monthNames[index],
                      style: AppTheme.bodyMedium.copyWith(
                        color: isSelected 
                            ? AppTheme.primaryText
                            : isCurrentMonth
                                ? AppTheme.greyPrimary
                                : AppTheme.secondaryText,
                        fontWeight: isSelected || isCurrentMonth 
                            ? FontWeight.w600 
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}